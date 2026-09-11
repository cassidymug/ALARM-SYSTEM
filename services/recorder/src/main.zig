// Guardian recorder daemon - continuous + event recording with 4K/8K support
const std = @import("std");
const common = @import("guardian-common");

const log = common.logging;
const types = common.types;
const EventBus = common.event_bus.EventBus;

const SERVICE_NAME = "recorder";

/// Recorder manages video+audio ingest from cameras
pub const Recorder = struct {
    allocator: std.mem.Allocator,
    event_bus: *EventBus,
    cameras: []RecorderCamera,
    config: types.SiteConfig,
    running: std.atomic.Value(bool),

    pub fn init(allocator: std.mem.Allocator, config: types.SiteConfig, event_bus: *EventBus) !Recorder {
        const cameras = try allocator.alloc(RecorderCamera, config.cameras.len);
        
        for (config.cameras, 0..) |cam_config, i| {
            cameras[i] = try RecorderCamera.init(allocator, cam_config);
        }

        return .{
            .allocator = allocator,
            .event_bus = event_bus,
            .cameras = cameras,
            .config = config,
            .running = std.atomic.Value(bool).init(false),
        };
    }

    pub fn deinit(self: *Recorder) void {
        for (self.cameras) |*camera| {
            camera.deinit();
        }
        self.allocator.free(self.cameras);
    }

    pub fn start(self: *Recorder) !void {
        log.info(SERVICE_NAME, "Starting recorder with {d} cameras", .{self.cameras.len});
        self.running.store(true, .seq_cst);

        // Start recording threads for each camera
        for (self.cameras) |*camera| {
            try camera.startRecording(self.event_bus);
        }

        // Main loop monitoring recorder health
        while (self.running.load(.seq_cst)) {
            std.time.sleep(5 * std.time.ns_per_s);
            self.checkCameraHealth();
        }

        log.info(SERVICE_NAME, "Recorder stopped", .{});
    }

    pub fn stop(self: *Recorder) void {
        log.info(SERVICE_NAME, "Stopping recorder", .{});
        self.running.store(false, .seq_cst);
        
        for (self.cameras) |*camera| {
            camera.stopRecording();
        }
    }

    fn checkCameraHealth(self: *Recorder) void {
        for (self.cameras) |camera| {
            if (!camera.is_recording) {
                log.warn(SERVICE_NAME, "Camera {s} not recording", .{camera.config.id});
            }
        }
    }
};

/// Per-camera recorder state
const RecorderCamera = struct {
    allocator: std.mem.Allocator,
    config: types.CameraConfig,
    is_recording: bool,
    current_segment: ?[]const u8,
    segments_recorded: u64,

    pub fn init(allocator: std.mem.Allocator, config: types.CameraConfig) !RecorderCamera {
        return .{
            .allocator = allocator,
            .config = config,
            .is_recording = false,
            .current_segment = null,
            .segments_recorded = 0,
        };
    }

    pub fn deinit(self: *RecorderCamera) void {
        if (self.current_segment) |segment| {
            self.allocator.free(segment);
        }
    }

    pub fn startRecording(self: *RecorderCamera, event_bus: *EventBus) !void {
        log.info(SERVICE_NAME, "Starting recording for camera {s} at {s} resolution", .{
            self.config.id,
            @tagName(self.config.max_resolution),
        });

        const width = self.config.max_resolution.getWidth();
        const height = self.config.max_resolution.getHeight();
        const bitrate = self.config.max_resolution.getEstimatedBitrateMbps();

        log.info(SERVICE_NAME, "Camera {s}: {d}x{d} @ ~{d}Mbps", .{
            self.config.id,
            width,
            height,
            bitrate,
        });

        // TODO: Actual ffmpeg/RTSP ingest pipeline
        // For now, stub marking as recording
        self.is_recording = true;

        // Simulate segment creation
        const segment_path = try std.fmt.allocPrint(
            self.allocator,
            "/srv/guardian/recordings/{s}/segment_{d}.mp4",
            .{ self.config.id, self.segments_recorded },
        );

        self.current_segment = segment_path;
        self.segments_recorded += 1;

        // Publish segment event
        event_bus.publish(.{ .recording_segment = .{
            .camera_id = self.config.id,
            .segment_path = segment_path,
            .start_time_ms = @intCast(std.time.milliTimestamp()),
            .duration_ms = 60000, // 1 minute segments
            .resolution = self.config.max_resolution,
            .is_event = false,
        } });
    }

    pub fn stopRecording(self: *RecorderCamera) void {
        log.info(SERVICE_NAME, "Stopping recording for camera {s}", .{self.config.id});
        self.is_recording = false;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.info(SERVICE_NAME, "Guardian recorder daemon starting", .{});

    // Load configuration
    // TODO: Implement actual config loading from /etc/guardian/
    const dummy_cameras = [_]types.CameraConfig{
        .{
            .id = "cam_front_gate",
            .name = "Front Gate",
            .rtsp_url = "rtsp://192.168.1.100:554/stream1",
            .rtsp_substream_url = "rtsp://192.168.1.100:554/stream2",
            .max_resolution = .uhd_4k,
            .audio_enabled = true,
            .detect_enabled = true,
            .intercom_enabled = true,
        },
        .{
            .id = "cam_driveway",
            .name = "Driveway",
            .rtsp_url = "rtsp://192.168.1.101:554/stream1",
            .max_resolution = .full_hd,
            .audio_enabled = true,
            .detect_enabled = true,
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

    // Initialize event bus
    var event_bus = EventBus.init(allocator);
    defer event_bus.deinit();

    // Initialize recorder
    var recorder = try Recorder.init(allocator, config, &event_bus);
    defer recorder.deinit();

    // Handle signals for graceful shutdown
    // TODO: Implement proper signal handling
    try recorder.start();
}

test "recorder camera initialization" {
    const cam_config = types.CameraConfig{
        .id = "test_cam",
        .name = "Test Camera",
        .rtsp_url = "rtsp://test:554/stream",
        .max_resolution = .uhd_8k,
        .audio_enabled = true,
        .detect_enabled = false,
        .intercom_enabled = false,
    };

    var camera = try RecorderCamera.init(std.testing.allocator, cam_config);
    defer camera.deinit();

    try std.testing.expectEqual(false, camera.is_recording);
    try std.testing.expectEqual(@as(u64, 0), camera.segments_recorded);
}
