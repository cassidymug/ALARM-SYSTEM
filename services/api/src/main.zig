// Guardian API daemon - local REST/gRPC for UI and services
const std = @import("std");
const common = @import("guardian-common");

const log = common.logging;
const types = common.types;
const EventBus = common.event_bus.EventBus;

const SERVICE_NAME = "api";

pub const ApiServer = struct {
    allocator: std.mem.Allocator,
    event_bus: *EventBus,
    config: types.SiteConfig,
    running: std.atomic.Value(bool),
    listen_addr: []const u8,

    pub fn init(allocator: std.mem.Allocator, config: types.SiteConfig, event_bus: *EventBus, listen_addr: []const u8) !ApiServer {
        return .{
            .allocator = allocator,
            .event_bus = event_bus,
            .config = config,
            .running = std.atomic.Value(bool).init(false),
            .listen_addr = listen_addr,
        };
    }

    pub fn deinit(self: *ApiServer) void {
        _ = self;
    }

    pub fn start(self: *ApiServer) !void {
        log.info(SERVICE_NAME, "Starting API server on {s}", .{self.listen_addr});
        self.running.store(true, .seq_cst);

        // TODO: HTTP server implementation using std.http
        // Endpoints:
        // - GET /api/v1/cameras
        // - GET /api/v1/cameras/:id/live
        // - GET /api/v1/alarm/status
        // - POST /api/v1/alarm/arm
        // - POST /api/v1/alarm/disarm
        // - GET /api/v1/recordings
        // - WebSocket /api/v1/events

        while (self.running.load(.seq_cst)) {
            std.time.sleep(1 * std.time.ns_per_s);
        }
    }

    pub fn stop(self: *ApiServer) void {
        log.info(SERVICE_NAME, "Stopping API server", .{});
        self.running.store(false, .seq_cst);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.info(SERVICE_NAME, "Guardian API daemon starting", .{});

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

    var api = try ApiServer.init(allocator, config, &event_bus, "127.0.0.1:8080");
    defer api.deinit();

    try api.start();
}
