// Guardian logging helpers
const std = @import("std");

pub const LogLevel = enum {
    debug,
    info,
    warn,
    err,
};

/// Simple structured logging to stdout/stderr for journald
pub fn log(
    comptime level: LogLevel,
    comptime service: []const u8,
    comptime fmt: []const u8,
    args: anytype,
) void {
    const writer = if (level == .err) std.io.getStdErr().writer() else std.io.getStdOut().writer();
    
    const level_str = switch (level) {
        .debug => "DEBUG",
        .info => "INFO",
        .warn => "WARN",
        .err => "ERROR",
    };
    
    const timestamp = std.time.milliTimestamp();
    
    writer.print("[{d}] [{s}] [{s}] " ++ fmt ++ "\n", .{
        timestamp, level_str, service,
    } ++ args) catch {};
}

pub fn debug(comptime service: []const u8, comptime fmt: []const u8, args: anytype) void {
    log(.debug, service, fmt, args);
}

pub fn info(comptime service: []const u8, comptime fmt: []const u8, args: anytype) void {
    log(.info, service, fmt, args);
}

pub fn warn(comptime service: []const u8, comptime fmt: []const u8, args: anytype) void {
    log(.warn, service, fmt, args);
}

pub fn err(comptime service: []const u8, comptime fmt: []const u8, args: anytype) void {
    log(.err, service, fmt, args);
}
