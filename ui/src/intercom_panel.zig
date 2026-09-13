// Intercom panel for gate/door two-way audio
const std = @import("std");
const common = @import("guardian-common");

const log = common.logging;

pub const IntercomPanel = struct {
    active_session: ?IntercomSession,

    pub fn init() IntercomPanel {
        return .{
            .active_session = null,
        };
    }

    pub fn render(self: *IntercomPanel) !void {
        // TODO: Render intercom UI
        // - List of intercom stations
        // - Current session state (ringing, answered, talking)
        // - Answer button (when ringing)
        // - Talk/mute button (when answered)
        // - Hangup button
        // - Audio level indicator
        _ = self;
    }

    pub fn answer(self: *IntercomPanel, station_id: []const u8) !void {
        log.info("intercom_panel", "Answering intercom: {s}", .{station_id});
        
        self.active_session = .{
            .station_id = station_id,
            .state = .answered,
            .started_ms = @intCast(std.time.milliTimestamp()),
        };

        // TODO: Signal guardian-intercom via API to establish WebRTC session
    }

    pub fn talk(self: *IntercomPanel, enable: bool) !void {
        if (self.active_session) |*session| {
            if (enable) {
                session.state = .talking;
                log.info("intercom_panel", "Talk enabled", .{});
            } else {
                session.state = .answered;
                log.info("intercom_panel", "Talk muted", .{});
            }
        }
    }

    pub fn hangup(self: *IntercomPanel) void {
        if (self.active_session) |session| {
            log.info("intercom_panel", "Hanging up: {s}", .{session.station_id});
            self.active_session = null;
            // TODO: Signal guardian-intercom to end session
        }
    }

    pub fn onRinging(self: *IntercomPanel, station_id: []const u8) void {
        log.info("intercom_panel", "Incoming ring: {s}", .{station_id});
        self.active_session = .{
            .station_id = station_id,
            .state = .ringing,
            .started_ms = @intCast(std.time.milliTimestamp()),
        };
        // TODO: Play ring tone
    }
};

const IntercomSession = struct {
    station_id: []const u8,
    state: SessionState,
    started_ms: u64,
};

const SessionState = enum {
    ringing,
    answered,
    talking,
};

test "intercom session lifecycle" {
    var panel = IntercomPanel.init();
    
    try std.testing.expectEqual(@as(?IntercomSession, null), panel.active_session);
    
    try panel.answer("gate_station");
    try std.testing.expect(panel.active_session != null);
    
    panel.hangup();
    try std.testing.expectEqual(@as(?IntercomSession, null), panel.active_session);
}
