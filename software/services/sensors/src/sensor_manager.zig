// Guardian sensor manager - handles all sensor types
const std = @import("std");
const common = @import("guardian-common");
const gxp = @import("gxp_protocol.zig");

const log = common.logging;
const types = common.types;
const EventBus = common.event_bus.EventBus;

const SERVICE_NAME = "sensors";

/// Multi-sensor manager supporting all sensor types
pub const SensorManager = struct {
    allocator: std.mem.Allocator,
    event_bus: *EventBus,
    config: types.SiteConfig,
    running: std.atomic.Value(bool),
    
    /// Zone state tracking
    zone_states: []ZoneState,
    
    /// Analog sensor readings
    analog_readings: []AnalogReading,
    
    /// Pulse counters (metal detectors)
    pulse_counters: []PulseCounter,
    
    /// Smoke detector state (latching)
    smoke_states: []SmokeState,
    
    pub const ZoneState = struct {
        triggered: bool = false,
        tamper: bool = false,
        fault: bool = false,
        last_change_ms: i64 = 0,
    };
    
    pub const AnalogReading = struct {
        value: f32 = 0.0,
        calibrated: f32 = 0.0,
        last_update_ms: i64 = 0,
        alarm_state: AlarmState = .normal,
    };
    
    pub const AlarmState = enum {
        normal,
        warning,
        critical,
        danger,
        extreme,
    };
    
    pub const PulseCounter = struct {
        count: u32 = 0,
        last_pulse_ms: i64 = 0,
        alarmed: bool = false,
    };
    
    pub const SmokeState = struct {
        alarmed: bool = false,
        latched: bool = false,
        tamper: bool = false,
        reset_time_ms: i64 = 0,
    };
    
    pub fn init(
        allocator: std.mem.Allocator,
        config: types.SiteConfig,
        event_bus: *EventBus,
    ) !SensorManager {
        const zone_states = try allocator.alloc(ZoneState, config.zones.len);
        @memset(zone_states, .{});
        
        const analog_readings = try allocator.alloc(AnalogReading, 8); // 8 analog inputs
        @memset(analog_readings, .{});
        
        const pulse_counters = try allocator.alloc(PulseCounter, 2); // 2 pulse inputs
        @memset(pulse_counters, .{});
        
        const smoke_states = try allocator.alloc(SmokeState, 4); // 4 smoke inputs
        @memset(smoke_states, .{});
        
        return .{
            .allocator = allocator,
            .event_bus = event_bus,
            .config = config,
            .running = std.atomic.Value(bool).init(false),
            .zone_states = zone_states,
            .analog_readings = analog_readings,
            .pulse_counters = pulse_counters,
            .smoke_states = smoke_states,
        };
    }
    
    pub fn deinit(self: *SensorManager) void {
        self.allocator.free(self.zone_states);
        self.allocator.free(self.analog_readings);
        self.allocator.free(self.pulse_counters);
        self.allocator.free(self.smoke_states);
    }
    
    pub fn start(self: *SensorManager) !void {
        log.info(SERVICE_NAME, "Starting multi-sensor manager", .{});
        self.running.store(true, .seq_cst);
        
        // Start monitoring threads
        const zone_thread = try std.Thread.spawn(.{}, pollZones, .{self});
        const analog_thread = try std.Thread.spawn(.{}, pollAnalogSensors, .{self});
        const smoke_thread = try std.Thread.spawn(.{}, pollSmokeDetectors, .{self});
        
        zone_thread.detach();
        analog_thread.detach();
        smoke_thread.detach();
        
        // Main loop
        while (self.running.load(.seq_cst)) {
            std.time.sleep(1 * std.time.ns_per_s);
        }
    }
    
    pub fn stop(self: *SensorManager) void {
        log.info(SERVICE_NAME, "Stopping sensor manager", .{});
        self.running.store(false, .seq_cst);
    }
    
    /// Poll contact sensors and PIR motion detectors (100ms cycle)
    fn pollZones(self: *SensorManager) void {
        // TODO: Connect to GXP expander
        var gxp_client = gxp.GXPClient.init(
            self.allocator,
            .{ .tcp = .{ .host = "192.168.1.100", .port = 9000 } },
        );
        defer gxp_client.disconnect();
        
        gxp_client.connect() catch |err| {
            log.err(SERVICE_NAME, "Failed to connect to GXP expander: {s}", .{@errorName(err)});
            return;
        };
        
        var last_bitmap: u32 = 0;
        
        while (self.running.load(.seq_cst)) {
            const now = std.time.milliTimestamp();
            
            // Poll all 32 zones
            const bitmap = gxp_client.pollZones() catch |err| {
                log.err(SERVICE_NAME, "Zone poll failed: {s}", .{@errorName(err)});
                std.time.sleep(1 * std.time.ns_per_s);
                continue;
            };
            
            // Detect changes
            const changed = bitmap ^ last_bitmap;
            if (changed != 0) {
                self.handleZoneChanges(bitmap, changed, now);
            }
            
            last_bitmap = bitmap;
            
            // 100ms poll cycle
            std.time.sleep(100 * std.time.ns_per_ms);
        }
    }
    
    fn handleZoneChanges(self: *SensorManager, bitmap: u32, changed: u32, timestamp: i64) void {
        var zone: u5 = 0;
        while (zone < 32) : (zone += 1) {
            const mask = @as(u32, 1) << zone;
            if ((changed & mask) != 0) {
                const triggered = (bitmap & mask) != 0;
                
                // Find zone config
                if (zone < self.config.zones.len) {
                    const zone_config = self.config.zones[zone];
                    self.zone_states[zone].triggered = triggered;
                    self.zone_states[zone].last_change_ms = timestamp;
                    
                    // Handle by sensor type
                    self.handleSensorEvent(zone_config, triggered, timestamp);
                }
            }
        }
    }
    
    fn handleSensorEvent(
        self: *SensorManager,
        zone_config: types.ZoneConfig,
        triggered: bool,
        timestamp: i64,
    ) void {
        switch (zone_config.sensor_type) {
            .door_window => {
                self.event_bus.publish(.{ .sensor_transition = .{
                    .zone_id = zone_config.id,
                    .sensor_id = zone_config.name,
                    .triggered = triggered,
                    .timestamp_ms = @intCast(timestamp),
                } });
                
                if (triggered and zone_config.chime_enabled) {
                    log.info(SERVICE_NAME, "CHIME: {s} opened", .{zone_config.name});
                }
            },
            
            .pir_motion => {
                log.info(SERVICE_NAME, "Motion detected: {s}", .{zone_config.name});
                self.event_bus.publish(.{ .detect_event = .{
                    .camera_id = zone_config.id,
                    .event_type = .motion,
                    .timestamp_ms = @intCast(timestamp),
                    .confidence = 1.0,
                } });
            },
            
            .glass_break => {
                if (triggered) {
                    log.warn(SERVICE_NAME, "GLASS BREAK: {s}", .{zone_config.name});
                    self.performActions(zone_config, .on_alarm);
                }
            },
            
            .panic_button => {
                if (triggered) {
                    log.err(SERVICE_NAME, "PANIC BUTTON: {s}", .{zone_config.name});
                    self.event_bus.publish(.{ .alarm_state_change = .{
                        .old_state = .armed_away,
                        .new_state = .alarm,
                        .timestamp_ms = @intCast(timestamp),
                        .reason = "Panic button pressed",
                    } });
                }
            },
            
            .water_leak => {
                if (triggered) {
                    log.warn(SERVICE_NAME, "WATER LEAK: {s}", .{zone_config.name});
                    self.performActions(zone_config, .on_warning);
                }
            },
            
            else => {
                log.debug(SERVICE_NAME, "Sensor {s}: triggered={}", .{
                    zone_config.name, triggered,
                });
            },
        }
    }
    
    /// Poll analog sensors (temperature, CO, gas, etc.) at 1Hz
    fn pollAnalogSensors(self: *SensorManager) void {
        while (self.running.load(.seq_cst)) {
            const now = std.time.milliTimestamp();
            
            // Read all 8 analog inputs (would read from GXP expander)
            for (self.analog_readings, 0..) |*reading, i| {
                // TODO: Read from GXP expander ADC
                const raw_value = self.readAnalogInput(@intCast(i)) catch continue;
                
                reading.value = raw_value;
                reading.calibrated = self.calibrateAnalogValue(i, raw_value);
                reading.last_update_ms = now;
                
                // Check thresholds
                self.checkAnalogThresholds(i, reading.calibrated, now);
            }
            
            // 1 Hz sample rate
            std.time.sleep(1 * std.time.ns_per_s);
        }
    }
    
    fn readAnalogInput(self: *SensorManager, input: u8) !f32 {
        // TODO: Implement GXP analog read command
        _ = self;
        _ = input;
        return 0.0; // Stub
    }
    
    fn calibrateAnalogValue(self: *SensorManager, input: usize, raw: f32) f32 {
        _ = self;
        
        // Temperature sensor (NTC 10kΩ thermistor)
        // Convert ADC value (0-3.3V) to temperature
        if (input == 0) {
            // Steinhart-Hart equation for NTC thermistor
            const voltage = raw;
            const resistance = (3.3 * 10000.0) / voltage - 10000.0;
            const ln_r = @log(resistance / 10000.0);
            const temp_k = 1.0 / (0.001129148 + (0.000234125 * ln_r) + (0.0000000876741 * ln_r * ln_r * ln_r));
            const temp_c = temp_k - 273.15;
            return @floatCast(temp_c);
        }
        
        // CO sensor (MQ-7, returns ppm)
        if (input == 1) {
            // Calibration curve for MQ-7
            const voltage = raw;
            const rs = (3.3 - voltage) / voltage * 10000.0;
            const ppm = @pow(f32, 10.0, ((std.math.log10(rs / 1000.0) - 0.8) / -0.4));
            return ppm;
        }
        
        return raw; // No calibration
    }
    
    fn checkAnalogThresholds(
        self: *SensorManager,
        input: usize,
        value: f32,
        timestamp: i64,
    ) void {
        // Find zone config for this analog input
        for (self.config.zones) |zone_config| {
            const thresholds = zone_config.thresholds orelse continue;
            
            var new_state = types.SensorManager.AlarmState.normal;
            
            // Check thresholds (highest priority first)
            if (thresholds.extreme) |extreme| {
                if (value >= extreme) new_state = .extreme;
            }
            if (thresholds.danger) |danger| {
                if (value >= danger and new_state == .normal) new_state = .danger;
            }
            if (thresholds.critical) |critical| {
                if (value >= critical and new_state == .normal) new_state = .critical;
            }
            if (thresholds.warning) |warning| {
                if (value >= warning and new_state == .normal) new_state = .warning;
            }
            
            const old_state = self.analog_readings[input].alarm_state;
            if (new_state != old_state) {
                self.analog_readings[input].alarm_state = new_state;
                
                log.warn(SERVICE_NAME, "{s}: {d:.2} - State: {s}", .{
                    zone_config.name, value, @tagName(new_state),
                });
                
                // Perform actions based on new state
                switch (new_state) {
                    .warning => self.performActions(zone_config, .on_warning),
                    .critical, .danger, .extreme => self.performActions(zone_config, .on_critical),
                    .normal => {},
                }
            }
        }
        
        _ = timestamp;
    }
    
    /// Poll smoke detectors (dedicated inputs, 500ms cycle)
    fn pollSmokeDetectors(self: *SensorManager) void {
        while (self.running.load(.seq_cst)) {
            const now = std.time.milliTimestamp();
            
            // Read all 4 smoke detector inputs
            for (self.smoke_states, 0..) |*state, i| {
                // TODO: Read from GXP smoke detector inputs
                const smoke_alarm = self.readSmokeInput(@intCast(i)) catch continue;
                
                if (smoke_alarm and !state.alarmed) {
                    // Smoke detected - latch alarm
                    state.alarmed = true;
                    state.latched = true;
                    
                    log.err(SERVICE_NAME, "SMOKE ALARM: Detector {d}", .{i + 1});
                    
                    // Trigger all smoke alarms (interconnected)
                    self.activateAllSmokeAlarms();
                    
                    // Fire alarm actions
                    self.event_bus.publish(.{ .alarm_state_change = .{
                        .old_state = .armed_away,
                        .new_state = .alarm,
                        .timestamp_ms = @intCast(now),
                        .reason = "Smoke detected",
                    } });
                    
                    // Call fire department
                    log.err(SERVICE_NAME, "Calling fire department!", .{});
                }
            }
            
            // 500ms poll cycle
            std.time.sleep(500 * std.time.ns_per_ms);
        }
    }
    
    fn readSmokeInput(self: *SensorManager, input: u8) !bool {
        // TODO: Implement GXP smoke input read
        _ = self;
        _ = input;
        return false; // Stub
    }
    
    fn activateAllSmokeAlarms(self: *SensorManager) void {
        log.info(SERVICE_NAME, "Activating all smoke alarms (interconnect)", .{});
        
        // TODO: Activate relays to trigger all smoke detectors
        // Set relay outputs 2+3 (siren + strobe)
        _ = self;
    }
    
    fn performActions(
        self: *SensorManager,
        zone_config: types.ZoneConfig,
        action_type: enum { on_warning, on_critical, on_alarm },
    ) void {
        const actions = zone_config.actions orelse return;
        
        const action_list = switch (action_type) {
            .on_warning => actions.on_warning,
            .on_critical => actions.on_critical,
            .on_alarm => actions.on_alarm,
        };
        
        for (action_list) |action| {
            switch (action) {
                .notify => log.info(SERVICE_NAME, "Action: Notify users", .{}),
                .alarm => log.warn(SERVICE_NAME, "Action: Trigger alarm", .{}),
                .call_fire_dept => log.err(SERVICE_NAME, "Action: Calling fire dept", .{}),
                .call_police => log.err(SERVICE_NAME, "Action: Calling police", .{}),
                .snapshot_camera => log.info(SERVICE_NAME, "Action: Snapshot cameras", .{}),
                .start_recording => log.info(SERVICE_NAME, "Action: Start recording", .{}),
                .activate_siren => log.info(SERVICE_NAME, "Action: Activate siren", .{}),
                .activate_strobe => log.info(SERVICE_NAME, "Action: Activate strobe", .{}),
                .unlock_doors => log.info(SERVICE_NAME, "Action: Unlock doors", .{}),
                .shut_down_hvac => log.info(SERVICE_NAME, "Action: Shut down HVAC", .{}),
                .turn_on_lights => log.info(SERVICE_NAME, "Action: Turn on lights", .{}),
                .evacuate => log.err(SERVICE_NAME, "Action: EVACUATE", .{}),
            }
        }
        
        _ = zone_config;
    }
};

test "sensor manager initialization" {
    const allocator = std.testing.allocator;
    
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
    
    var manager = try SensorManager.init(allocator, config, &event_bus);
    defer manager.deinit();
    
    try std.testing.expect(!manager.running.load(.seq_cst));
}
