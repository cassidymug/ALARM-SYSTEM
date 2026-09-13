// Guardian recorder - RTSP ingest implementation
//
// **Approach**: Spawn ffmpeg as a subprocess per camera
//
// **Rationale**:
// - Minimal dependencies: ffmpeg is a system package, no C bindings needed
// - Mature and battle-tested for all RTSP/RTP/codec combinations
// - Handles reconnection, format negotiation, and codec support
// - Consistent with minimal-deps goal (explicit helper, not hidden dependency sprawl)
//
// **Alternative considered**: libav C bindings
// - More integrated but adds C dependency and complexity
// - Would need to handle codec negotiation, RTP parsing, etc. in Zig
// - ffmpeg CLI already does this well
//
// **Process per camera**:
// 1. Spawn ffmpeg with RTSP input and segment output
// 2. Monitor stderr for connection status
// 3. Restart on failure with exponential backoff
// 4. Publish segment events to event bus
//

const std = @import("std");
const common = @import("guardian-common");

const log = common.logging;
const types = common.types;
const EventBus = common.event_bus.EventBus;

const SERVICE_NAME = "recorder";

/// FFmpeg recorder process per camera
pub const FFmpegRecorder = struct {
    allocator: std.mem.Allocator,
    config: types.CameraConfig,
    event_bus: *EventBus,
    
    process: ?std.process.Child = null,
    running: std.atomic.Value(bool),
    reconnect_count: std.atomic.Value(u32),
    
    output_dir: []const u8,
    segment_duration_s: u32 = 60,

    pub fn init(
        allocator: std.mem.Allocator,
        config: types.CameraConfig,
        event_bus: *EventBus,
        output_dir: []const u8,
    ) !FFmpegRecorder {
        return .{
            .allocator = allocator,
            .config = config,
            .event_bus = event_bus,
            .running = std.atomic.Value(bool).init(false),
            .reconnect_count = std.atomic.Value(u32).init(0),
            .output_dir = output_dir,
        };
    }

    pub fn deinit(self: *FFmpegRecorder) void {
        self.stop();
    }

    pub fn start(self: *FFmpegRecorder) !void {
        self.running.store(true, .seq_cst);
        
        // Create output directory
        std.fs.makeDirAbsolute(self.output_dir) catch |err| {
            if (err != error.PathAlreadyExists) return err;
        };

        while (self.running.load(.seq_cst)) {
            self.startFFmpeg() catch |err| {
                const count = self.reconnect_count.fetchAdd(1, .seq_cst);
                log.err(SERVICE_NAME, "Camera {s} failed: {s}, reconnect #{d}", .{
                    self.config.id, @errorName(err), count + 1,
                });
                
                // Exponential backoff: 1s, 2s, 4s, 8s, max 30s
                const delay_s: u64 = @min(30, @as(u64, 1) << @intCast(@min(count, 5)));
                std.time.sleep(delay_s * std.time.ns_per_s);
                continue;
            };
            
            // Reset reconnect count on successful run
            self.reconnect_count.store(0, .seq_cst);
        }
    }

    pub fn stop(self: *FFmpegRecorder) void {
        self.running.store(false, .seq_cst);
        
        if (self.process) |*proc| {
            _ = proc.kill() catch {};
            _ = proc.wait() catch {};
            self.process = null;
        }
    }

    fn startFFmpeg(self: *FFmpegRecorder) !void {
        const width = self.config.max_resolution.getWidth();
        const height = self.config.max_resolution.getHeight();
        
        log.info(SERVICE_NAME, "Starting RTSP ingest: {s} at {d}x{d}", .{
            self.config.id, width, height,
        });

        // Build ffmpeg command
        // ffmpeg -rtsp_transport tcp -i <rtsp_url> \
        //   -c:v copy -c:a copy \
        //   -f segment -segment_time 60 -segment_format mp4 \
        //   -reset_timestamps 1 \
        //   -strftime 1 \
        //   <output_dir>/%Y%m%d_%H%M%S.mp4
        
        const output_pattern = try std.fmt.allocPrint(
            self.allocator,
            "{s}/%Y%m%d_%H%M%S.mp4",
            .{self.output_dir},
        );
        defer self.allocator.free(output_pattern);

        const segment_time_str = try std.fmt.allocPrint(
            self.allocator,
            "{d}",
            .{self.segment_duration_s},
        );
        defer self.allocator.free(segment_time_str);

        const argv = [_][]const u8{
            "ffmpeg",
            "-rtsp_transport", "tcp",
            "-i", self.config.rtsp_url,
            "-c:v", "copy",
            "-c:a", if (self.config.audio_enabled) "copy" else "none",
            "-f", "segment",
            "-segment_time", segment_time_str,
            "-segment_format", "mp4",
            "-reset_timestamps", "1",
            "-strftime", "1",
            "-loglevel", "warning",
            output_pattern,
        };

        var proc = std.process.Child.init(&argv, self.allocator);
        proc.stderr_behavior = .Pipe;
        proc.stdout_behavior = .Ignore;
        
        try proc.spawn();
        self.process = proc;
        
        log.info(SERVICE_NAME, "FFmpeg started for camera {s} (PID {d})", .{
            self.config.id, proc.id,
        });

        // Monitor stderr in separate thread for connection status
        const stderr_thread = try std.Thread.spawn(.{}, monitorStderr, .{
            self.allocator,
            self.config.id,
            proc.stderr.?,
        });
        stderr_thread.detach();

        // Monitor output directory for new segments
        const monitor_thread = try std.Thread.spawn(.{}, monitorSegments, .{
            self,
        });
        monitor_thread.detach();

        // Wait for process
        const term = try proc.wait();
        self.process = null;

        switch (term) {
            .Exited => |code| {
                if (code != 0) {
                    return error.FFmpegExited;
                }
            },
            .Signal, .Stopped, .Unknown => return error.FFmpegKilled,
        }
    }

    fn monitorStderr(allocator: std.mem.Allocator, camera_id: []const u8, stderr: std.fs.File) void {
        defer stderr.close();
        
        var buf_reader = std.io.bufferedReader(stderr.reader());
        var reader = buf_reader.reader();
        
        var line_buf: [4096]u8 = undefined;
        while (reader.readUntilDelimiterOrEof(&line_buf, '\n') catch null) |line| {
            // Log ffmpeg warnings/errors
            if (std.mem.indexOf(u8, line, "error") != null or
                std.mem.indexOf(u8, line, "Error") != null)
            {
                log.err(SERVICE_NAME, "FFmpeg ({s}): {s}", .{ camera_id, line });
            } else if (std.mem.indexOf(u8, line, "warning") != null) {
                log.warn(SERVICE_NAME, "FFmpeg ({s}): {s}", .{ camera_id, line });
            }
        }
        
        _ = allocator;
    }

    fn monitorSegments(self: *FFmpegRecorder) void {
        var last_check: i64 = 0;
        var segment_count: u64 = 0;

        while (self.running.load(.seq_cst)) {
            std.time.sleep(5 * std.time.ns_per_s);
            
            const now = std.time.milliTimestamp();
            if (now - last_check < 5000) continue;
            last_check = now;

            // Check for new segments (simplified - in production would use inotify)
            var dir = std.fs.openDirAbsolute(self.output_dir, .{ .iterate = true }) catch continue;
            defer dir.close();

            var iter = dir.iterate();
            while (iter.next() catch null) |entry| {
                if (entry.kind != .file) continue;
                if (!std.mem.endsWith(u8, entry.name, ".mp4")) continue;

                // Get file info
                const stat = dir.statFile(entry.name) catch continue;
                
                // Check if file was created recently (within last segment duration)
                const mtime_ms = @divFloor(@as(i64, @intCast(stat.mtime)), 1_000_000);
                if (now - mtime_ms < self.segment_duration_s * 1000) {
                    const path = std.fmt.allocPrint(
                        self.allocator,
                        "{s}/{s}",
                        .{ self.output_dir, entry.name },
                    ) catch continue;

                    segment_count += 1;

                    self.event_bus.publish(.{ .recording_segment = .{
                        .camera_id = self.config.id,
                        .segment_path = path,
                        .start_time_ms = @intCast(now - (self.segment_duration_s * 1000)),
                        .duration_ms = self.segment_duration_s * 1000,
                        .resolution = self.config.max_resolution,
                        .is_event = false,
                    } });

                    log.info(SERVICE_NAME, "Segment #{d} recorded: {s}", .{
                        segment_count, path,
                    });
                }
            }
        }
    }
};

/// Recorder manages multiple camera recorders
pub const Recorder = struct {
    allocator: std.mem.Allocator,
    event_bus: *EventBus,
    cameras: []FFmpegRecorder,
    config: types.SiteConfig,
    running: std.atomic.Value(bool),
    threads: std.ArrayList(std.Thread),

    pub fn init(allocator: std.mem.Allocator, config: types.SiteConfig, event_bus: *EventBus) !Recorder {
        const cameras = try allocator.alloc(FFmpegRecorder, config.cameras.len);
        errdefer allocator.free(cameras);
        
        for (config.cameras, 0..) |cam_config, i| {
            const output_dir = try std.fmt.allocPrint(
                allocator,
                "/srv/guardian/recordings/{s}",
                .{cam_config.id},
            );
            
            cameras[i] = try FFmpegRecorder.init(allocator, cam_config, event_bus, output_dir);
        }

        return .{
            .allocator = allocator,
            .event_bus = event_bus,
            .cameras = cameras,
            .config = config,
            .running = std.atomic.Value(bool).init(false),
            .threads = std.ArrayList(std.Thread).init(allocator),
        };
    }

    pub fn deinit(self: *Recorder) void {
        self.stop();
        
        for (self.cameras) |*camera| {
            camera.deinit();
        }
        self.allocator.free(self.cameras);
        self.threads.deinit();
    }

    pub fn start(self: *Recorder) !void {
        log.info(SERVICE_NAME, "Starting recorder with {d} cameras", .{self.cameras.len});
        self.running.store(true, .seq_cst);

        // Start each camera in its own thread
        for (self.cameras) |*camera| {
            const thread = try std.Thread.spawn(.{}, startCameraThread, .{camera});
            try self.threads.append(thread);
        }

        // Wait for shutdown signal
        while (self.running.load(.seq_cst)) {
            std.time.sleep(1 * std.time.ns_per_s);
        }
    }

    pub fn stop(self: *Recorder) void {
        log.info(SERVICE_NAME, "Stopping recorder", .{});
        self.running.store(false, .seq_cst);
        
        for (self.cameras) |*camera| {
            camera.stop();
        }

        for (self.threads.items) |thread| {
            thread.join();
        }
    }

    fn startCameraThread(camera: *FFmpegRecorder) void {
        camera.start() catch |err| {
            log.err(SERVICE_NAME, "Camera {s} thread failed: {s}", .{
                camera.config.id, @errorName(err),
            });
        };
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.info(SERVICE_NAME, "Guardian recorder daemon starting", .{});

    // TODO: Load config from /etc/guardian/site.json
    const dummy_cameras = [_]types.CameraConfig{
        .{
            .id = "cam_test",
            .name = "Test Camera",
            .rtsp_url = "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mp4",
            .rtsp_substream_url = null,
            .max_resolution = .full_hd,
            .audio_enabled = true,
            .detect_enabled = false,
            .intercom_enabled = false,
        },
    };

    const config = types.SiteConfig{
        .site_name = "Test Site",
        .cameras = &dummy_cameras,
        .zones = &.{},
        .backup_scope = .events_only,
        .backup_retention_days = 30,
        .backup_bandwidth_cap_mbps = 10,
        .relay_url = "wss://relay.guardian.example.com",
    };

    var event_bus = EventBus.init(allocator);
    defer event_bus.deinit();

    var recorder = try Recorder.init(allocator, config, &event_bus);
    defer recorder.deinit();

    try recorder.start();
}

test "ffmpeg recorder initialization" {
    const allocator = std.testing.allocator;
    
    const cam_config = types.CameraConfig{
        .id = "test_cam",
        .name = "Test Camera",
        .rtsp_url = "rtsp://test:554/stream",
        .max_resolution = .uhd_4k,
        .audio_enabled = true,
        .detect_enabled = false,
        .intercom_enabled = false,
    };

    var event_bus = EventBus.init(allocator);
    defer event_bus.deinit();

    var recorder = try FFmpegRecorder.init(allocator, cam_config, &event_bus, "/tmp/test");
    defer recorder.deinit();

    try std.testing.expect(!recorder.running.load(.seq_cst));
}
