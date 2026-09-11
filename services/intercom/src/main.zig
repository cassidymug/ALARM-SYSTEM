// Guardian intercom daemon - two-way audio for gate/door stations
const std = @import("std");
const common = @import("guardian-common");

const log = common.logging;
const types = common.types;
const EventBus = common.event_bus.EventBus;

const SERVICE_NAME = "intercom";

pub const IntercomManager = struct {
    allocator: std.mem.Allocator,
    event_bus: *EventBus,
    config: types.SiteConfig,
    running: std.atomic.Value(bool),
    active_sessions: std.ArrayList(IntercomSession),

    pub fn init(allocator: std.mem.Allocator, config: types.SiteConfig, event_bus: *EventBus) !IntercomManager {
        return .{
            .allocator = allocator,
            .event_bus = event_bus,
            .config = config,
            .running = std.atomic.Value(bool).init(false),
            .active_sessions = std.ArrayList(IntercomSession).init(allocator),
        };
    }

    pub fn deinit(self: *IntercomManager) void {
        self.active_sessions.deinit();
    }

    pub fn start(self: *IntercomManager) !void {
        log.info(SERVICE_NAME, "Starting intercom manager", .{});
        self.running.store(true, .seq_cst);

        // TODO: WebRTC signaling via guardian-relay
        // TODO: Handle ring/answer/talk/hangup

        while (self.running.load(.seq_cst)) {
            std.time.sleep(1 * std.time.ns_per_s);
        }
    }

    pub fn stop(self: *IntercomManager) void {
        log.info(SERVICE_NAME, "Stopping intercom manager", .{});
        self.running.store(false, .seq_cst);
    }

    fn ring(self: *IntercomManager, station_id: []const u8) void {
        log.info(SERVICE_NAME, "Intercom ringing: {s}", .{station_id});
        self.event_bus.publish(.{ .intercom_session = .{
            .station_id = station_id,
            .session_state = .ringing,
            .timestamp_ms = @intCast(std.time.milliTimestamp()),
        } });
    }
};

const IntercomSession = struct {
    station_id: []const u8,
    started_ms: u64,
    state: common.event_bus.IntercomState,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.info(SERVICE_NAME, "Guardian intercom daemon starting", .{});

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

    var intercom = try IntercomManager.init(allocator, config, &event_bus);
    defer intercom.deinit();

    try intercom.start();
}
