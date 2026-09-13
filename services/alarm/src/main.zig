// Guardian alarm daemon - state machine and zone management
const std = @import("std");
const common = @import("guardian-common");

const log = common.logging;
const types = common.types;
const EventBus = common.event_bus.EventBus;
const Event = common.event_bus.Event;

const SERVICE_NAME = "alarm";

pub const AlarmSystem = struct {
    allocator: std.mem.Allocator,
    event_bus: *EventBus,
    config: types.SiteConfig,
    state: types.AlarmState,
    running: std.atomic.Value(bool),
    exit_delay_timer: ?i64,
    entry_delay_timer: ?i64,

    pub fn init(allocator: std.mem.Allocator, config: types.SiteConfig, event_bus: *EventBus) !AlarmSystem {
        return .{
            .allocator = allocator,
            .event_bus = event_bus,
            .config = config,
            .state = .disarmed,
            .running = std.atomic.Value(bool).init(false),
            .exit_delay_timer = null,
            .entry_delay_timer = null,
        };
    }

    pub fn deinit(self: *AlarmSystem) void {
        _ = self;
    }

    pub fn start(self: *AlarmSystem) !void {
        log.info(SERVICE_NAME, "Starting alarm system with {d} zones", .{self.config.zones.len});
        self.running.store(true, .seq_cst);

        // Subscribe to sensor transitions
        try self.event_bus.subscribe(&onSensorTransition);

        while (self.running.load(.seq_cst)) {
            self.updateTimers();
            std.time.sleep(100 * std.time.ns_per_ms);
        }
    }

    pub fn stop(self: *AlarmSystem) void {
        log.info(SERVICE_NAME, "Stopping alarm system", .{});
        self.running.store(false, .seq_cst);
    }

    pub fn arm(self: *AlarmSystem, mode: types.ArmingMode) !void {
        log.info(SERVICE_NAME, "Arming system: {s}", .{@tagName(mode)});

        const old_state = self.state;
        
        switch (mode) {
            .armed_away, .armed_stay => {
                self.state = .exit_delay;
                self.exit_delay_timer = std.time.milliTimestamp() + 30000; // 30s exit delay
            },
            .disarmed => {
                self.state = .disarmed;
                self.exit_delay_timer = null;
                self.entry_delay_timer = null;
            },
        }

        self.publishStateChange(old_state, self.state, "User armed");
    }

    pub fn disarm(self: *AlarmSystem) void {
        log.info(SERVICE_NAME, "Disarming system", .{});
        
        const old_state = self.state;
        self.state = .disarmed;
        self.exit_delay_timer = null;
        self.entry_delay_timer = null;

        self.publishStateChange(old_state, self.state, "User disarmed");
    }

    fn updateTimers(self: *AlarmSystem) void {
        const now = std.time.milliTimestamp();

        // Check exit delay expiration
        if (self.exit_delay_timer) |exit_time| {
            if (now >= exit_time) {
                const old_state = self.state;
                self.state = .armed_away; // TODO: Determine away vs stay from arming mode
                self.exit_delay_timer = null;
                self.publishStateChange(old_state, self.state, "Exit delay expired");
            }
        }

        // Check entry delay expiration
        if (self.entry_delay_timer) |entry_time| {
            if (now >= entry_time) {
                const old_state = self.state;
                self.state = .alarm;
                self.entry_delay_timer = null;
                self.publishStateChange(old_state, self.state, "Entry delay expired");
                self.triggerAlarm();
            }
        }
    }

    fn triggerAlarm(self: *AlarmSystem) void {
        log.warn(SERVICE_NAME, "ALARM TRIGGERED", .{});
        // TODO: Activate siren, send notifications
        _ = self;
    }

    fn publishStateChange(self: *AlarmSystem, old_state: types.AlarmState, new_state: types.AlarmState, reason: []const u8) void {
        self.event_bus.publish(.{ .alarm_state_change = .{
            .old_state = old_state,
            .new_state = new_state,
            .timestamp_ms = @intCast(std.time.milliTimestamp()),
            .reason = reason,
        } });
    }

    fn onSensorTransition(event: Event) void {
        if (event == .sensor_transition) {
            const transition = event.sensor_transition;
            log.info(SERVICE_NAME, "Sensor {s} in zone {s}: {s}", .{
                transition.sensor_id,
                transition.zone_id,
                if (transition.triggered) "TRIGGERED" else "normal",
            });
            // TODO: Zone logic and state transitions
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.info(SERVICE_NAME, "Guardian alarm daemon starting", .{});

    const dummy_zones = [_]types.ZoneConfig{
        .{
            .id = "zone_front_door",
            .name = "Front Door",
            .zone_type = .perimeter,
            .sensor_bindings = &.{"sensor_front_door"},
            .entry_delay_ms = 30000,
        },
        .{
            .id = "zone_living_room",
            .name = "Living Room",
            .zone_type = .interior,
            .sensor_bindings = &.{"sensor_living_pir"},
        },
    };

    const config = types.SiteConfig{
        .site_name = "Test Site",
        .cameras = &.{},
        .zones = &dummy_zones,
        .backup_scope = .events_only,
        .backup_retention_days = 30,
        .backup_bandwidth_cap_mbps = 10,
        .relay_url = "wss://relay.guardian.example.com",
    };

    var event_bus = EventBus.init(allocator);
    defer event_bus.deinit();

    var alarm = try AlarmSystem.init(allocator, config, &event_bus);
    defer alarm.deinit();

    try alarm.start();
}
