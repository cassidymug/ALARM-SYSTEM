// Guardian eXpander Protocol (GXP) - Binary protocol for 32-zone wired expanders
// Designed for RS-485 or Ethernet communication with zone expander hardware

const std = @import("std");

/// GXP protocol constants
pub const GXP_HEADER: [2]u8 = .{ 0xA5, 0x5A }; // Magic bytes
pub const GXP_MAX_PAYLOAD = 256;
pub const GXP_FRAME_OVERHEAD = 7; // header(2) + cmd(1) + len(2) + crc(2)
pub const GXP_MAX_FRAME = GXP_FRAME_OVERHEAD + GXP_MAX_PAYLOAD;

/// GXP command codes
pub const Command = enum(u8) {
    /// Poll all 32 zones, response contains 4-byte bitmap
    poll_zones = 0x01,
    
    /// Get configuration for a specific zone
    get_zone_config = 0x02,
    
    /// Set configuration for a specific zone
    set_zone_config = 0x03,
    
    /// Get expander status (tamper, AC loss, battery voltage)
    get_status = 0x10,
    
    /// Set expander configuration (poll rate, tamper settings)
    set_expander_config = 0x11,
    
    /// Get firmware version
    get_version = 0x20,
    
    /// Soft reset expander
    reset = 0xFF,
    
    _,
};

/// Zone configuration types
pub const ZoneType = enum(u8) {
    /// Normally closed (NC) zone
    nc = 0x00,
    /// Normally open (NO) zone
    no = 0x01,
    /// End-of-line (EOL) resistor supervised
    eol = 0x02,
    /// Disabled/unused zone
    disabled = 0xFF,
    
    _,
};

/// Zone state
pub const ZoneState = enum(u8) {
    normal = 0x00,
    triggered = 0x01,
    fault = 0x02,    // Open/short circuit
    tamper = 0x03,   // Tamper detected
    
    _,
};

/// Expander status flags
pub const StatusFlags = packed struct {
    ac_power: bool,
    battery_low: bool,
    tamper: bool,
    comm_error: bool,
    reserved: u4 = 0,
};

/// Zone configuration
pub const ZoneConfig = struct {
    zone_number: u8, // 1-32
    zone_type: ZoneType,
    eol_resistance_ohm: u16, // For EOL zones
    response_time_ms: u16,   // Debounce time
};

/// Expander status
pub const ExpanderStatus = struct {
    flags: StatusFlags,
    battery_voltage_mv: u16,
    temperature_c: i8,
    uptime_seconds: u32,
};

/// GXP frame structure
pub const Frame = struct {
    header: [2]u8 = GXP_HEADER,
    command: Command,
    payload_len: u16,
    payload: [GXP_MAX_PAYLOAD]u8 = undefined,
    
    /// Calculate CRC-16/MODBUS
    pub fn calculateCRC(data: []const u8) u16 {
        var crc: u16 = 0xFFFF;
        
        for (data) |byte| {
            crc ^= @as(u16, byte);
            var i: u8 = 0;
            while (i < 8) : (i += 1) {
                if (crc & 0x0001 != 0) {
                    crc = (crc >> 1) ^ 0xA001;
                } else {
                    crc >>= 1;
                }
            }
        }
        
        return crc;
    }
    
    /// Serialize frame to bytes
    pub fn serialize(self: *const Frame, allocator: std.mem.Allocator) ![]u8 {
        const total_len = GXP_FRAME_OVERHEAD + self.payload_len;
        var buffer = try allocator.alloc(u8, total_len);
        errdefer allocator.free(buffer);
        
        // Header
        buffer[0] = self.header[0];
        buffer[1] = self.header[1];
        
        // Command
        buffer[2] = @intFromEnum(self.command);
        
        // Payload length (little-endian)
        buffer[3] = @intCast(self.payload_len & 0xFF);
        buffer[4] = @intCast((self.payload_len >> 8) & 0xFF);
        
        // Payload
        if (self.payload_len > 0) {
            @memcpy(buffer[5..5+self.payload_len], self.payload[0..self.payload_len]);
        }
        
        // CRC (exclude CRC itself)
        const crc = calculateCRC(buffer[0..total_len-2]);
        buffer[total_len-2] = @intCast(crc & 0xFF);
        buffer[total_len-1] = @intCast((crc >> 8) & 0xFF);
        
        return buffer;
    }
    
    /// Deserialize frame from bytes
    pub fn deserialize(data: []const u8) !Frame {
        if (data.len < GXP_FRAME_OVERHEAD) {
            return error.FrameTooShort;
        }
        
        // Verify header
        if (data[0] != GXP_HEADER[0] or data[1] != GXP_HEADER[1]) {
            return error.InvalidHeader;
        }
        
        const command: Command = @enumFromInt(data[2]);
        const payload_len: u16 = @as(u16, data[3]) | (@as(u16, data[4]) << 8);
        
        if (payload_len > GXP_MAX_PAYLOAD) {
            return error.PayloadTooLarge;
        }
        
        const expected_len = GXP_FRAME_OVERHEAD + payload_len;
        if (data.len < expected_len) {
            return error.FrameTooShort;
        }
        
        // Verify CRC
        const received_crc: u16 = @as(u16, data[expected_len-2]) | (@as(u16, data[expected_len-1]) << 8);
        const calculated_crc = calculateCRC(data[0..expected_len-2]);
        
        if (received_crc != calculated_crc) {
            return error.CRCMismatch;
        }
        
        var frame = Frame{
            .command = command,
            .payload_len = payload_len,
        };
        
        if (payload_len > 0) {
            @memcpy(frame.payload[0..payload_len], data[5..5+payload_len]);
        }
        
        return frame;
    }
};

/// GXP client for communicating with zone expanders
pub const GXPClient = struct {
    allocator: std.mem.Allocator,
    transport: Transport,
    timeout_ms: u64 = 1000,
    
    pub const Transport = union(enum) {
        serial: SerialTransport,
        tcp: TCPTransport,
    };
    
    pub const SerialTransport = struct {
        port_path: []const u8, // e.g., /dev/ttyUSB0
        baud_rate: u32 = 115200,
        file: ?std.fs.File = null,
    };
    
    pub const TCPTransport = struct {
        host: []const u8,
        port: u16,
        stream: ?std.net.Stream = null,
    };
    
    pub fn init(allocator: std.mem.Allocator, transport: Transport) GXPClient {
        return .{
            .allocator = allocator,
            .transport = transport,
        };
    }
    
    /// Connect to the expander
    pub fn connect(self: *GXPClient) !void {
        switch (self.transport) {
            .serial => |*serial| {
                // Open serial port
                serial.file = try std.fs.openFileAbsolute(
                    serial.port_path,
                    .{ .mode = .read_write },
                );
                
                // Configure serial port (baud rate, 8N1)
                // Note: This requires platform-specific ioctl calls
                // For production, use a serial port library
            },
            .tcp => |*tcp| {
                // Connect to TCP socket
                const address = try std.net.Address.parseIp(tcp.host, tcp.port);
                tcp.stream = try std.net.tcpConnectToAddress(address);
            },
        }
    }
    
    /// Disconnect from the expander
    pub fn disconnect(self: *GXPClient) void {
        switch (self.transport) {
            .serial => |*serial| {
                if (serial.file) |file| {
                    file.close();
                    serial.file = null;
                }
            },
            .tcp => |*tcp| {
                if (tcp.stream) |stream| {
                    stream.close();
                    tcp.stream = null;
                }
            },
        }
    }
    
    /// Send a frame and receive response
    pub fn sendCommand(self: *GXPClient, frame: *const Frame) !Frame {
        const tx_data = try frame.serialize(self.allocator);
        defer self.allocator.free(tx_data);
        
        // Send frame
        switch (self.transport) {
            .serial => |serial| {
                if (serial.file) |file| {
                    _ = try file.writeAll(tx_data);
                } else return error.NotConnected;
            },
            .tcp => |tcp| {
                if (tcp.stream) |stream| {
                    _ = try stream.writeAll(tx_data);
                } else return error.NotConnected;
            },
        }
        
        // Receive response with timeout
        const start_time = std.time.milliTimestamp();
        var rx_buffer: [GXP_MAX_FRAME]u8 = undefined;
        var rx_len: usize = 0;
        
        while (rx_len < GXP_FRAME_OVERHEAD) {
            if (std.time.milliTimestamp() - start_time > self.timeout_ms) {
                return error.Timeout;
            }
            
            const bytes_read = switch (self.transport) {
                .serial => |serial| blk: {
                    if (serial.file) |file| {
                        break :blk try file.read(rx_buffer[rx_len..]);
                    } else return error.NotConnected;
                },
                .tcp => |tcp| blk: {
                    if (tcp.stream) |stream| {
                        break :blk try stream.read(rx_buffer[rx_len..]);
                    } else return error.NotConnected;
                },
            };
            
            if (bytes_read == 0) {
                return error.ConnectionClosed;
            }
            
            rx_len += bytes_read;
        }
        
        // Read remaining payload based on length field
        const payload_len: u16 = @as(u16, rx_buffer[3]) | (@as(u16, rx_buffer[4]) << 8);
        const total_expected = GXP_FRAME_OVERHEAD + payload_len;
        
        while (rx_len < total_expected) {
            if (std.time.milliTimestamp() - start_time > self.timeout_ms) {
                return error.Timeout;
            }
            
            const bytes_read = switch (self.transport) {
                .serial => |serial| blk: {
                    if (serial.file) |file| {
                        break :blk try file.read(rx_buffer[rx_len..]);
                    } else return error.NotConnected;
                },
                .tcp => |tcp| blk: {
                    if (tcp.stream) |stream| {
                        break :blk try stream.read(rx_buffer[rx_len..]);
                    } else return error.NotConnected;
                },
            };
            
            if (bytes_read == 0) {
                return error.ConnectionClosed;
            }
            
            rx_len += bytes_read;
        }
        
        // Deserialize response
        return try Frame.deserialize(rx_buffer[0..rx_len]);
    }
    
    /// Poll all 32 zones, returns bitmap of triggered zones
    pub fn pollZones(self: *GXPClient) !u32 {
        const cmd_frame = Frame{
            .command = .poll_zones,
            .payload_len = 0,
        };
        
        const response = try self.sendCommand(&cmd_frame);
        
        if (response.payload_len != 4) {
            return error.InvalidResponse;
        }
        
        // Reconstruct 32-bit zone bitmap (little-endian)
        const bitmap: u32 = @as(u32, response.payload[0]) |
                           (@as(u32, response.payload[1]) << 8) |
                           (@as(u32, response.payload[2]) << 16) |
                           (@as(u32, response.payload[3]) << 24);
        
        return bitmap;
    }
    
    /// Get configuration for a specific zone (1-32)
    pub fn getZoneConfig(self: *GXPClient, zone_number: u8) !ZoneConfig {
        if (zone_number < 1 or zone_number > 32) {
            return error.InvalidZoneNumber;
        }
        
        var cmd_frame = Frame{
            .command = .get_zone_config,
            .payload_len = 1,
        };
        cmd_frame.payload[0] = zone_number;
        
        const response = try self.sendCommand(&cmd_frame);
        
        if (response.payload_len < 6) {
            return error.InvalidResponse;
        }
        
        return ZoneConfig{
            .zone_number = response.payload[0],
            .zone_type = @enumFromInt(response.payload[1]),
            .eol_resistance_ohm = @as(u16, response.payload[2]) | (@as(u16, response.payload[3]) << 8),
            .response_time_ms = @as(u16, response.payload[4]) | (@as(u16, response.payload[5]) << 8),
        };
    }
    
    /// Set configuration for a specific zone
    pub fn setZoneConfig(self: *GXPClient, config: ZoneConfig) !void {
        var cmd_frame = Frame{
            .command = .set_zone_config,
            .payload_len = 6,
        };
        
        cmd_frame.payload[0] = config.zone_number;
        cmd_frame.payload[1] = @intFromEnum(config.zone_type);
        cmd_frame.payload[2] = @intCast(config.eol_resistance_ohm & 0xFF);
        cmd_frame.payload[3] = @intCast((config.eol_resistance_ohm >> 8) & 0xFF);
        cmd_frame.payload[4] = @intCast(config.response_time_ms & 0xFF);
        cmd_frame.payload[5] = @intCast((config.response_time_ms >> 8) & 0xFF);
        
        _ = try self.sendCommand(&cmd_frame);
    }
    
    /// Get expander status (tamper, power, battery)
    pub fn getStatus(self: *GXPClient) !ExpanderStatus {
        const cmd_frame = Frame{
            .command = .get_status,
            .payload_len = 0,
        };
        
        const response = try self.sendCommand(&cmd_frame);
        
        if (response.payload_len < 8) {
            return error.InvalidResponse;
        }
        
        const flags: StatusFlags = @bitCast(response.payload[0]);
        const battery_voltage_mv: u16 = @as(u16, response.payload[1]) | (@as(u16, response.payload[2]) << 8);
        const temperature_c: i8 = @bitCast(response.payload[3]);
        const uptime_seconds: u32 = @as(u32, response.payload[4]) |
                                   (@as(u32, response.payload[5]) << 8) |
                                   (@as(u32, response.payload[6]) << 16) |
                                   (@as(u32, response.payload[7]) << 24);
        
        return ExpanderStatus{
            .flags = flags,
            .battery_voltage_mv = battery_voltage_mv,
            .temperature_c = temperature_c,
            .uptime_seconds = uptime_seconds,
        };
    }
    
    /// Reset the expander
    pub fn reset(self: *GXPClient) !void {
        const cmd_frame = Frame{
            .command = .reset,
            .payload_len = 0,
        };
        
        _ = try self.sendCommand(&cmd_frame);
    }
};

test "GXP frame serialization" {
    const allocator = std.testing.allocator;
    
    var frame = Frame{
        .command = .poll_zones,
        .payload_len = 0,
    };
    
    const data = try frame.serialize(allocator);
    defer allocator.free(data);
    
    // Verify header
    try std.testing.expectEqual(GXP_HEADER[0], data[0]);
    try std.testing.expectEqual(GXP_HEADER[1], data[1]);
    
    // Verify command
    try std.testing.expectEqual(@intFromEnum(Command.poll_zones), data[2]);
    
    // Verify length
    try std.testing.expectEqual(@as(u8, 0), data[3]);
    try std.testing.expectEqual(@as(u8, 0), data[4]);
    
    // Frame should have CRC
    try std.testing.expectEqual(@as(usize, 7), data.len);
}

test "GXP frame deserialization" {
    const allocator = std.testing.allocator;
    
    // Create a frame
    var original = Frame{
        .command = .get_status,
        .payload_len = 0,
    };
    
    const data = try original.serialize(allocator);
    defer allocator.free(data);
    
    // Deserialize it
    const parsed = try Frame.deserialize(data);
    
    try std.testing.expectEqual(original.command, parsed.command);
    try std.testing.expectEqual(original.payload_len, parsed.payload_len);
}

test "GXP CRC calculation" {
    const test_data = [_]u8{ 0xA5, 0x5A, 0x01, 0x00, 0x00 };
    const crc = Frame.calculateCRC(&test_data);
    
    // CRC should be deterministic
    const crc2 = Frame.calculateCRC(&test_data);
    try std.testing.expectEqual(crc, crc2);
}

test "zone bitmap parsing" {
    // Zone 1 and zone 32 triggered
    const bitmap: u32 = 0x80000001;
    
    const zone1_triggered = (bitmap & (1 << 0)) != 0;
    const zone32_triggered = (bitmap & (1 << 31)) != 0;
    const zone16_triggered = (bitmap & (1 << 15)) != 0;
    
    try std.testing.expect(zone1_triggered);
    try std.testing.expect(zone32_triggered);
    try std.testing.expect(!zone16_triggered);
}
