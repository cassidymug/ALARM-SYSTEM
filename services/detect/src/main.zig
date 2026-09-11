// Guardian detect daemon - motion and object detection
const std = @import("std");
const common = @import("guardian-common");

const log = common.logging;
const types = common.types;
const EventBus = common.event_bus.EventBus;
const Event = common.event_bus.Event;

const SERVICE_NAME = "detect";

pub const Detector = struct {
    allocator: std.mem.Allocator,
    event_bus: *EventBus,
    config: types.SiteConfig,
    running: std.atomic.Value(bool),

    pub fn init(allocator: std.mem.Allocator, config: types.SiteConfig, event_bus: *EventBus) !Detector {
        return .{
            .allocator = allocator,
            .event_bus = event_bus,
            .config = config,
            .running = std.atomic.Value(bool).init(false),
        };
    }

    pub fn deinit(self: *Detector) void {
        _ = self;
    }

    pub fn start(self: *Detector) !void {
        log.info(SERVICE_NAME, "Starting detector", .{});
        self.running.store(true, .seq_cst);

        // Subscribe to recording segment events to analyze
        try self.event_bus.subscribe(&onRecordingSegment);

        while (self.running.load(.seq_cst)) {
            std.time.sleep(1 * std.time.ns_per_s);
        }
    }

    pub fn stop(self: *Detector) void {
        log.info(SERVICE_NAME, "Stopping detector", .{});
        self.running.store(false, .seq_cst);
    }

    fn onRecordingSegment(event: Event) void {
        if (event == .recording_segment) {
            const segment = event.recording_segment;
            log.debug(SERVICE_NAME, "Analyzing segment: {s}", .{segment.segment_path});
            // TODO: Actual motion/object detection
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.info(SERVICE_NAME, "Guardian detect daemon starting", .{});

    const config = types.SiteConfig{
        .site_name = "Test Site",
        .cameras = &.{},
        .zones = &.{},
        .backup_scope = .events_only,
        .backup_retention_days = 30,
        .backup_bandwidth_cap_mbps = 10,
        .relay_url = "wss://relay.guardian.example.com",
    };

    var event_bus = EventBus.init(allocator);
    defer event_bus.deinit();

    var detector = try Detector.init(allocator, config, &event_bus);
    defer detector.deinit();

    try detector.start();
}
