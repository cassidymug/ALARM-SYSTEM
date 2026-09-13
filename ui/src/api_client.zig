// API Client for guardian-ui to communicate with guardian-api
const std = @import("std");
const common = @import("guardian-common");

const types = common.types;
const log = common.logging;

const SERVICE_NAME = "ui-api";

/// API Client for guardian-api REST/WebSocket communication
pub const ApiClient = struct {
    allocator: std.mem.Allocator,
    base_url: []const u8,
    connected: std.atomic.Value(bool),

    pub fn init(allocator: std.mem.Allocator, base_url: []const u8) ApiClient {
        return .{
            .allocator = allocator,
            .base_url = base_url,
            .connected = std.atomic.Value(bool).init(false),
        };
    }

    pub fn deinit(self: *ApiClient) void {
        _ = self;
    }

    /// Get list of configured cameras
    pub fn getCameras(self: *ApiClient) ![]types.CameraConfig {
        _ = self;
        // TODO: HTTP GET /api/v1/cameras
        log.info(SERVICE_NAME, "API: getCameras() - stub", .{});
        return error.NotImplemented;
    }

    /// Get current alarm status
    pub fn getAlarmStatus(self: *ApiClient) !types.AlarmState {
        _ = self;
        // TODO: HTTP GET /api/v1/alarm/status
        log.info(SERVICE_NAME, "API: getAlarmStatus() - stub", .{});
        return .disarmed;
    }

    /// Arm the alarm system
    pub fn armAlarm(self: *ApiClient, mode: types.ArmingMode, pin: []const u8) !void {
        _ = self;
        _ = mode;
        _ = pin;
        // TODO: HTTP POST /api/v1/alarm/arm
        log.info(SERVICE_NAME, "API: armAlarm() - stub", .{});
    }

    /// Disarm the alarm system
    pub fn disarmAlarm(self: *ApiClient, pin: []const u8) !void {
        _ = self;
        _ = pin;
        // TODO: HTTP POST /api/v1/alarm/disarm
        log.info(SERVICE_NAME, "API: disarmAlarm() - stub", .{});
    }

    /// Get recent detection events
    pub fn getDetectionEvents(
        self: *ApiClient,
        limit: u32,
        event_type: ?types.DetectionType,
    ) ![]types.DetectionEvent {
        _ = self;
        _ = limit;
        _ = event_type;
        // TODO: HTTP GET /api/v1/detections?limit=N&type=X
        log.info(SERVICE_NAME, "API: getDetectionEvents() - stub", .{});
        return error.NotImplemented;
    }

    /// Get camera snapshot (JPEG)
    pub fn getCameraSnapshot(self: *ApiClient, camera_id: []const u8) ![]const u8 {
        _ = self;
        _ = camera_id;
        // TODO: HTTP GET /api/v1/cameras/{id}/snapshot
        log.info(SERVICE_NAME, "API: getCameraSnapshot() - stub", .{});
        return error.NotImplemented;
    }

    /// Update camera detection capabilities
    pub fn updateCameraDetection(
        self: *ApiClient,
        camera_id: []const u8,
        capabilities: types.DetectionCapabilities,
    ) !void {
        _ = self;
        _ = camera_id;
        _ = capabilities;
        // TODO: HTTP PUT /api/v1/cameras/{id}/detection
        log.info(SERVICE_NAME, "API: updateCameraDetection() - stub", .{});
    }

    /// Subscribe to real-time events via WebSocket
    pub fn subscribeEvents(self: *ApiClient, callback: *const fn (types.DetectionEvent) void) !void {
        _ = self;
        _ = callback;
        // TODO: WebSocket connection to /api/v1/events
        log.info(SERVICE_NAME, "API: subscribeEvents() - stub", .{});
    }

    /// Check API connectivity
    pub fn ping(self: *ApiClient) !void {
        _ = self;
        // TODO: HTTP GET /api/v1/health
        log.info(SERVICE_NAME, "API: ping() - stub", .{});
    }
};
