// Arm/disarm keypad interface
const std = @import("std");
const common = @import("guardian-common");

const types = common.types;
const log = common.logging;

pub const ArmKeypad = struct {
    pin_buffer: [8]u8,
    pin_length: usize,
    current_state: types.AlarmState,

    pub fn init() ArmKeypad {
        return .{
            .pin_buffer = undefined,
            .pin_length = 0,
            .current_state = .disarmed,
        };
    }

    pub fn render(self: *ArmKeypad) !void {
        // TODO: Render keypad UI
        // - Current alarm state display (DISARMED, ARMED AWAY, ARMED STAY, ALARM)
        // - PIN entry field (masked)
        // - Number buttons 0-9
        // - ARM AWAY button
        // - ARM STAY button
        // - DISARM button
        // - Clear button
        _ = self;
    }

    pub fn addDigit(self: *ArmKeypad, digit: u8) void {
        if (self.pin_length < self.pin_buffer.len and digit >= '0' and digit <= '9') {
            self.pin_buffer[self.pin_length] = digit;
            self.pin_length += 1;
        }
    }

    pub fn clear(self: *ArmKeypad) void {
        self.pin_length = 0;
    }

    pub fn getCurrentPin(self: *ArmKeypad) []const u8 {
        return self.pin_buffer[0..self.pin_length];
    }

    pub fn armAway(self: *ArmKeypad, pin: []const u8) !void {
        // TODO: Validate PIN with guardian-api
        // TODO: Send arm command to guardian-alarm via API
        log.info("arm_keypad", "Arming system (away) with PIN", .{});
        _ = self;
        _ = pin;
    }

    pub fn armStay(self: *ArmKeypad, pin: []const u8) !void {
        // TODO: Validate PIN and arm (stay mode)
        log.info("arm_keypad", "Arming system (stay) with PIN", .{});
        _ = self;
        _ = pin;
    }

    pub fn disarm(self: *ArmKeypad, pin: []const u8) !void {
        // TODO: Validate PIN and disarm
        log.info("arm_keypad", "Disarming system with PIN", .{});
        _ = self;
        _ = pin;
    }

    pub fn updateState(self: *ArmKeypad, new_state: types.AlarmState) void {
        self.current_state = new_state;
    }
};

test "keypad PIN entry" {
    var keypad = ArmKeypad.init();
    
    keypad.addDigit('1');
    keypad.addDigit('2');
    keypad.addDigit('3');
    keypad.addDigit('4');
    
    const pin = keypad.getCurrentPin();
    try std.testing.expectEqualStrings("1234", pin);
    
    keypad.clear();
    try std.testing.expectEqual(@as(usize, 0), keypad.pin_length);
}
