// Guardian event bus - in-process pub/sub for service coordination
const std = @import("std");
const types = @import("types.zig");

/// Event types published on the bus
pub const Event = union(enum) {
    /// Sensor state transition
    sensor_transition: SensorTransition,
    /// Alarm state change
    alarm_state_change: AlarmStateChange,
    /// Motion or object detection event
    detect_event: DetectEvent,
    /// Recording segment completed
    recording_segment: RecordingSegment,
    /// Intercom session event
    intercom_session: IntercomSession,
    /// Backup progress
    backup_progress: BackupProgress,
    /// Gateway connectivity change
    gateway_status: GatewayStatus,
};

pub const SensorTransition = struct {
    zone_id: []const u8,
    sensor_id: []const u8,
    triggered: bool,
    timestamp_ms: u64,
};

pub const AlarmStateChange = struct {
    old_state: types.AlarmState,
    new_state: types.AlarmState,
    timestamp_ms: u64,
    reason: []const u8,
};

pub const DetectEvent = struct {
    camera_id: []const u8,
    event_type: DetectType,
    timestamp_ms: u64,
    confidence: f32,
};

pub const DetectType = enum {
    motion,
    person,
    vehicle,
};

pub const RecordingSegment = struct {
    camera_id: []const u8,
    segment_path: []const u8,
    start_time_ms: u64,
    duration_ms: u64,
    resolution: types.ResolutionProfile,
    is_event: bool,
};

pub const IntercomSession = struct {
    station_id: []const u8,
    session_state: IntercomState,
    timestamp_ms: u64,
};

pub const IntercomState = enum {
    ringing,
    answered,
    talking,
    ended,
};

pub const BackupProgress = struct {
    total_bytes: u64,
    uploaded_bytes: u64,
    current_file: []const u8,
};

pub const GatewayStatus = struct {
    connected: bool,
    timestamp_ms: u64,
    error_message: ?[]const u8,
};

/// Simple in-process event bus using callbacks
pub const EventBus = struct {
    allocator: std.mem.Allocator,
    subscribers: std.ArrayList(Subscriber),
    mutex: std.Thread.Mutex,

    const Subscriber = struct {
        callback: *const fn (Event) void,
    };

    pub fn init(allocator: std.mem.Allocator) EventBus {
        return .{
            .allocator = allocator,
            .subscribers = std.ArrayList(Subscriber).init(allocator),
            .mutex = .{},
        };
    }

    pub fn deinit(self: *EventBus) void {
        self.subscribers.deinit();
    }

    /// Subscribe to all events
    pub fn subscribe(self: *EventBus, callback: *const fn (Event) void) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        try self.subscribers.append(.{ .callback = callback });
    }

    /// Publish an event to all subscribers
    pub fn publish(self: *EventBus, event: Event) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        for (self.subscribers.items) |subscriber| {
            subscriber.callback(event);
        }
    }
};

test "event bus basic publish/subscribe" {
    var bus = EventBus.init(std.testing.allocator);
    defer bus.deinit();

    const TestCtx = struct {
        var received_count: usize = 0;
        
        fn callback(event: Event) void {
            _ = event;
            received_count += 1;
        }
    };
    
    try bus.subscribe(&TestCtx.callback);
    
    bus.publish(.{ .gateway_status = .{
        .connected = true,
        .timestamp_ms = 1000,
        .error_message = null,
    }});
    
    try std.testing.expectEqual(@as(usize, 1), TestCtx.received_count);
}
