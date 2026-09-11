// Guardian sensors daemon - zone I/O management
const std = @import("std");
const common = @import("guardian-common");

const log = common.logging;
const types = common.types;
const EventBus = common.event_bus.EventBus;

const SERVICE_NAME = "sensors";

pub const SensorManager = struct {
    allocator: std.mem.Allocator,
    event_bus: *EventBus,
    config: types.SiteConfig,
    running: std.atomic.Value(bool),

    pub fn init(allocator: std.mem.Allocator, config: types.SiteConfig, event_bus: *EventBus) !SensorManager {
        return .{
            .allocator = allocator,
            .event_bus = event_bus,
            .config = config,
            .running = std.atomic.Value(bool).init(false),
        };
    }

    pub fn deinit(self: *SensorManager) void {
        _ = self;
    }

    pub fn start(self: *SensorManager) !void {
        log.info(SERVICE_NAME, "Starting sensor manager with {d} zones", .{self.config.zones.len});
        self.running.store(true, .seq_cst);

        // TODO: Initialize GPIO/USB/serial/IP sensor interfaces
        // TODO: Poll or listen for sensor state changes

        while (self.running.load(.seq_cst)) {
            self.pollSensors();
            std.time.sleep(100 * std.time.ns_per_ms);
        }
    }

    pub fn stop(self: *SensorManager) void {
        log.info(SERVICE_NAME, "Stopping sensor manager", .{});
        self.running.store(false, .seq_cst);
    }

    fn pollSensors(self: *SensorManager) void {
        // TODO: Read actual sensor states from hardware
        // For now, stub only
        _ = self;
    }

    fn publishSensorTransition(self: *SensorManager, zone_id: []const u8, sensor_id: []const u8, triggered: bool) void {
        self.event_bus.publish(.{ .sensor_transition = .{
            .zone_id = zone_id,
            .sensor_id = sensor_id,
            .triggered = triggered,
            .timestamp_ms = @intCast(std.time.milliTimestamp()),
        } });
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.info(SERVICE_NAME, "Guardian sensors daemon starting", .{});

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

    var sensors = try SensorManager.init(allocator, config, &event_bus);
    defer sensors.deinit();

    try sensors.start();
}
