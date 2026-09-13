// Guardian RTSP client with modern codec support (H.264, H.265, AV1)
// Optimized for 4K/8K recording with hardware acceleration

const std = @import("std");
const common = @import("guardian-common");
const log = common.logging;

const SERVICE_NAME = "recorder.rtsp";

/// Codec types supported by the recorder
pub const Codec = enum {
    h264,  // H.264/AVC - universal support
    h265,  // H.265/HEVC - better compression, 4K/8K standard
    av1,   // AV1 - future-proof, open, best compression
    
    pub fn toFFmpegCodec(self: Codec) []const u8 {
        return switch (self) {
            .h264 => "h264",
            .h265 => "hevc",
            .av1 => "av1",
        };
    }
    
    pub fn getEstimatedBitrate(self: Codec, width: u32, height: u32, fps: u32) u32 {
        const pixels = width * height;
        const baseline_bitrate = switch (self) {
            .h264 => pixels * fps / 30000, // ~0.1 bits/pixel
            .h265 => pixels * fps / 50000, // ~40% savings vs H.264
            .av1 => pixels * fps / 65000,  // ~30% savings vs H.265
        };
        return baseline_bitrate;
    }
};

/// Hardware acceleration methods
pub const HWAccel = enum {
    none,
    vaapi,     // Intel/AMD (Linux)
    nvenc,     // NVIDIA
    qsv,       // Intel QuickSync
    videotoolbox, // Apple
    
    pub fn toFFmpegFlag(self: HWAccel) ?[]const u8 {
        return switch (self) {
            .none => null,
            .vaapi => "vaapi",
            .nvenc => "cuda",
            .qsv => "qsv",
            .videotoolbox => "videotoolbox",
        };
    }
};

/// RTSP transport protocol
pub const RTSPTransport = enum {
    tcp,  // Reliable, works through firewalls
    udp,  // Lower latency, may have packet loss
    
    pub fn toFFmpegFlag(self: RTSPTransport) []const u8 {
        return switch (self) {
            .tcp => "tcp",
            .udp => "udp",
        };
    }
};

/// Recording mode
pub const RecordingMode = enum {
    continuous,      // Always recording
    motion_triggered, // Record on motion + buffer
    event_triggered,  // Record only on alarm events
};

/// RTSP stream configuration
pub const RTSPStreamConfig = struct {
    /// RTSP URL (e.g., rtsp://192.168.1.100:554/stream1)
    url: []const u8,
    
    /// Username for RTSP authentication
    username: ?[]const u8 = null,
    
    /// Password for RTSP authentication
    password: ?[]const u8 = null,
    
    /// Transport protocol
    transport: RTSPTransport = .tcp,
    
    /// Timeout for RTSP connection (seconds)
    timeout_s: u32 = 10,
    
    /// Whether to analyze stream metadata before recording
    analyze_stream: bool = true,
    
    /// Buffer size in seconds (for motion-triggered recording)
    buffer_duration_s: u32 = 30,
    
    /// Reconnect strategy
    max_reconnect_attempts: u32 = 0, // 0 = infinite
    reconnect_delay_s: u32 = 5,
};

/// Recording configuration
pub const RecordingConfig = struct {
    /// Output directory for recordings
    output_dir: []const u8,
    
    /// Segment duration in seconds (0 = single file)
    segment_duration_s: u32 = 300, // 5 minutes default
    
    /// Recording mode
    mode: RecordingMode = .continuous,
    
    /// Codec to use (none = copy stream codec)
    codec: ?Codec = null,
    
    /// Hardware acceleration
    hwaccel: HWAccel = .none,
    
    /// Whether to include audio
    audio_enabled: bool = true,
    
    /// Whether to enable timestamps on video
    timestamp_overlay: bool = false,
    
    /// Quality/bitrate control
    quality: Quality = .high,
    
    /// Storage management
    max_storage_gb: ?u64 = null,
    retention_days: u32 = 30,
};

pub const Quality = enum {
    low,    // Lower bitrate for longer storage
    medium, // Balanced
    high,   // High quality for evidence
    lossless, // Visually lossless (huge files)
    
    pub fn getCRF(self: Quality, codec: Codec) u8 {
        // CRF (Constant Rate Factor): 0 = lossless, 51 = worst
        return switch (codec) {
            .h264, .h265 => switch (self) {
                .low => 28,
                .medium => 23,
                .high => 20,
                .lossless => 17,
            },
            .av1 => switch (self) {
                .low => 35,
                .medium => 30,
                .high => 25,
                .lossless => 20,
            },
        };
    }
};

/// FFmpeg command builder for modern RTSP recording
pub const FFmpegCommandBuilder = struct {
    allocator: std.mem.Allocator,
    stream_config: RTSPStreamConfig,
    recording_config: RecordingConfig,
    
    pub fn init(
        allocator: std.mem.Allocator,
        stream_config: RTSPStreamConfig,
        recording_config: RecordingConfig,
    ) FFmpegCommandBuilder {
        return .{
            .allocator = allocator,
            .stream_config = stream_config,
            .recording_config = recording_config,
        };
    }
    
    /// Build ffmpeg argv for 4K/8K capable recording
    pub fn buildCommand(self: *FFmpegCommandBuilder, camera_id: []const u8) ![]const []const u8 {
        var args = std.ArrayList([]const u8).init(self.allocator);
        errdefer args.deinit();
        
        try args.append("ffmpeg");
        
        // Global options
        try args.append("-nostdin");
        try args.append("-hide_banner");
        
        // Hardware acceleration (before input)
        if (self.recording_config.hwaccel.toFFmpegFlag()) |hwaccel| {
            try args.append("-hwaccel");
            try args.append(hwaccel);
        }
        
        // RTSP transport
        try args.append("-rtsp_transport");
        try args.append(self.stream_config.transport.toFFmpegFlag());
        
        // Timeout
        const timeout_str = try std.fmt.allocPrint(
            self.allocator,
            "{d}",
            .{self.stream_config.timeout_s * 1_000_000}, // microseconds
        );
        try args.append("-timeout");
        try args.append(timeout_str);
        
        // Analyze stream metadata
        if (self.stream_config.analyze_stream) {
            try args.append("-analyzeduration");
            try args.append("5000000"); // 5 seconds
            try args.append("-probesize");
            try args.append("10000000"); // 10MB
        }
        
        // Buffer size (important for motion-triggered recording)
        const buffer_frames = self.stream_config.buffer_duration_s * 30; // assume 30fps
        const buffer_str = try std.fmt.allocPrint(
            self.allocator,
            "{d}",
            .{buffer_frames},
        );
        try args.append("-buffer_size");
        try args.append(buffer_str);
        
        // Build RTSP URL with auth if needed
        const input_url = if (self.stream_config.username) |username| blk: {
            const password = self.stream_config.password orelse "";
            // rtsp://user:pass@host/path
            const at_pos = std.mem.indexOf(u8, self.stream_config.url, "//") orelse 0;
            const protocol = self.stream_config.url[0..at_pos+2];
            const rest = self.stream_config.url[at_pos+2..];
            
            break :blk try std.fmt.allocPrint(
                self.allocator,
                "{s}{s}:{s}@{s}",
                .{protocol, username, password, rest},
            );
        } else self.stream_config.url;
        
        try args.append("-i");
        try args.append(input_url);
        
        // Video codec
        if (self.recording_config.codec) |codec| {
            // Transcode to specified codec
            try args.append("-c:v");
            
            const codec_name = switch (self.recording_config.hwaccel) {
                .none => codec.toFFmpegCodec(),
                .nvenc => if (codec == .h264) "h264_nvenc" else "hevc_nvenc",
                .qsv => if (codec == .h264) "h264_qsv" else "hevc_qsv",
                .vaapi => if (codec == .h264) "h264_vaapi" else "hevc_vaapi",
                .videotoolbox => if (codec == .h264) "h264_videotoolbox" else "hevc_videotoolbox",
            };
            try args.append(codec_name);
            
            // Quality control (CRF)
            const crf = self.recording_config.quality.getCRF(codec);
            const crf_str = try std.fmt.allocPrint(self.allocator, "{d}", .{crf});
            try args.append("-crf");
            try args.append(crf_str);
            
            // Preset for encoding speed
            try args.append("-preset");
            try args.append("medium"); // balanced speed/quality
        } else {
            // Copy codec from stream (no transcoding)
            try args.append("-c:v");
            try args.append("copy");
        }
        
        // Audio codec
        try args.append("-c:a");
        if (self.recording_config.audio_enabled) {
            try args.append("aac"); // Universal compatibility
            try args.append("-b:a");
            try args.append("128k");
        } else {
            try args.append("none");
        }
        
        // Timestamp overlay (if enabled)
        if (self.recording_config.timestamp_overlay) {
            try args.append("-vf");
            try args.append("drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='%{localtime\\:%Y-%m-%d %H\\\\:%M\\\\:%S}':x=10:y=10:fontsize=24:fontcolor=white:box=1:boxcolor=black@0.5");
        }
        
        // Output format (segmented recording)
        if (self.recording_config.segment_duration_s > 0) {
            try args.append("-f");
            try args.append("segment");
            
            const segment_time_str = try std.fmt.allocPrint(
                self.allocator,
                "{d}",
                .{self.recording_config.segment_duration_s},
            );
            try args.append("-segment_time");
            try args.append(segment_time_str);
            
            try args.append("-segment_format");
            try args.append("mp4");
            
            try args.append("-reset_timestamps");
            try args.append("1");
            
            try args.append("-strftime");
            try args.append("1");
            
            // MP4 faststart for streaming
            try args.append("-movflags");
            try args.append("+faststart");
        }
        
        // Output path
        const output_pattern = if (self.recording_config.segment_duration_s > 0) 
            try std.fmt.allocPrint(
                self.allocator,
                "{s}/{s}_%Y%m%d_%H%M%S.mp4",
                .{self.recording_config.output_dir, camera_id},
            )
        else
            try std.fmt.allocPrint(
                self.allocator,
                "{s}/{s}_continuous.mp4",
                .{self.recording_config.output_dir, camera_id},
            );
        try args.append(output_pattern);
        
        // Loglevel
        try args.append("-loglevel");
        try args.append("info");
        
        return try args.toOwnedSlice();
    }
    
    pub fn deinit(self: *FFmpegCommandBuilder) void {
        _ = self;
    }
};

/// Detect available hardware acceleration
pub fn detectHWAccel(allocator: std.mem.Allocator) !HWAccel {
    // Try to detect NVIDIA GPU
    {
        var proc = std.process.Child.init(&[_][]const u8{"nvidia-smi"}, allocator);
        proc.stdout_behavior = .Ignore;
        proc.stderr_behavior = .Ignore;
        
        if (proc.spawnAndWait()) |term| {
            if (term == .Exited and term.Exited == 0) {
                log.info(SERVICE_NAME, "Detected NVIDIA GPU, using NVENC", .{});
                return .nvenc;
            }
        } else |_| {}
    }
    
    // Try to detect Intel QuickSync
    {
        var proc = std.process.Child.init(&[_][]const u8{"vainfo"}, allocator);
        proc.stdout_behavior = .Pipe;
        proc.stderr_behavior = .Ignore;
        
        if (proc.spawn()) |_| {
            defer _ = proc.wait() catch {};
            
            if (proc.stdout) |stdout| {
                var buf_reader = std.io.bufferedReader(stdout.reader());
                var reader = buf_reader.reader();
                
                var line_buf: [1024]u8 = undefined;
                while (reader.readUntilDelimiterOrEof(&line_buf, '\n') catch null) |line| {
                    if (std.mem.indexOf(u8, line, "Intel") != null) {
                        log.info(SERVICE_NAME, "Detected Intel GPU, using QSV", .{});
                        return .qsv;
                    }
                    if (std.mem.indexOf(u8, line, "AMD") != null or 
                        std.mem.indexOf(u8, line, "Radeon") != null) {
                        log.info(SERVICE_NAME, "Detected AMD GPU, using VAAPI", .{});
                        return .vaapi;
                    }
                }
            }
        } else |_| {}
    }
    
    log.info(SERVICE_NAME, "No hardware acceleration detected, using software encoding", .{});
    return .none;
}

test "ffmpeg command builder for 4K H.265" {
    const allocator = std.testing.allocator;
    
    const stream_config = RTSPStreamConfig{
        .url = "rtsp://192.168.1.100:554/stream1",
        .username = "admin",
        .password = "password123",
        .transport = .tcp,
    };
    
    const recording_config = RecordingConfig{
        .output_dir = "/srv/guardian/recordings/cam1",
        .segment_duration_s = 300,
        .codec = .h265,
        .quality = .high,
        .hwaccel = .nvenc,
    };
    
    var builder = FFmpegCommandBuilder.init(allocator, stream_config, recording_config);
    defer builder.deinit();
    
    const argv = try builder.buildCommand("cam1");
    defer allocator.free(argv);
    
    // Verify key flags are present
    var has_nvenc = false;
    var has_h265 = false;
    for (argv) |arg| {
        if (std.mem.eql(u8, arg, "hevc_nvenc")) has_h265 = true;
        if (std.mem.eql(u8, arg, "cuda")) has_nvenc = true;
    }
    
    try std.testing.expect(has_h265 or has_nvenc);
}

test "codec bitrate estimation for 4K" {
    const bitrate_h264 = Codec.h264.getEstimatedBitrate(3840, 2160, 30);
    const bitrate_h265 = Codec.h265.getEstimatedBitrate(3840, 2160, 30);
    const bitrate_av1 = Codec.av1.getEstimatedBitrate(3840, 2160, 30);
    
    // H.265 should be ~40% less than H.264
    // AV1 should be ~30% less than H.265
    try std.testing.expect(bitrate_h265 < bitrate_h264);
    try std.testing.expect(bitrate_av1 < bitrate_h265);
}
