// Guardian gateway daemon - outbound relay client (mTLS/WebSocket)
const std = @import("std");
const common = @import("guardian-common");

const log = common.logging;
const types = common.types;
const EventBus = common.event_bus.EventBus;

const SERVICE_NAME = "gateway";

pub const GatewayClient = struct {
    allocator: std.mem.Allocator,
    event_bus: *EventBus,
    config: types.SiteConfig,
    running: std.atomic.Value(bool),
    connected: std.atomic.Value(bool),

    pub fn init(allocator: std.mem.Allocator, config: types.SiteConfig, event_bus: *EventBus) !GatewayClient {
        return .{
            .allocator = allocator,
            .event_bus = event_bus,
            .config = config,
            .running = std.atomic.Value(bool).init(false),
            .connected = std.atomic.Value(bool).init(false),
        };
    }

    pub fn deinit(self: *GatewayClient) void {
        _ = self;
    }

    pub fn start(self: *GatewayClient) !void {
        log.info(SERVICE_NAME, "Starting gateway client, connecting to {s}", .{self.config.relay_url});
        self.running.store(true, .seq_cst);

        // TODO: mTLS/WebSocket connection to guardian-relay
        // TODO: Subscribe to events and forward to relay
        // TODO: Handle remote signaling for live view and intercom

        while (self.running.load(.seq_cst)) {
            if (!self.connected.load(.seq_cst)) {
                self.connect();
            }
            std.time.sleep(5 * std.time.ns_per_s);
        }
    }

    pub fn stop(self: *GatewayClient) void {
        log.info(SERVICE_NAME, "Stopping gateway client", .{});
        self.running.store(false, .seq_cst);
    }

    fn connect(self: *GatewayClient) void {
        log.info(SERVICE_NAME, "Connecting to relay...", .{});
        // TODO: Actual mTLS/WebSocket connection
        // For now, stub
        _ = self;
    }

    fn publishStatus(self: *GatewayClient, connected: bool) void {
        self.event_bus.publish(.{ .gateway_status = .{
            .connected = connected,
            .timestamp_ms = @intCast(std.time.milliTimestamp()),
            .error_message = null,
        } });
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.info(SERVICE_NAME, "Guardian gateway daemon starting", .{});

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

    var gateway = try GatewayClient.init(allocator, config, &event_bus);
    defer gateway.deinit();

    try gateway.start();
}
