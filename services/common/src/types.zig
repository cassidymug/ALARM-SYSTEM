// Guardian shared types
const std = @import("std");

/// Camera configuration with resolution profile support (Full HD, 4K, 8K)
pub const CameraConfig = struct {
    id: []const u8,
    name: []const u8,
    rtsp_url: []const u8,
    rtsp_substream_url: ?[]const u8 = null,
    
    /// Maximum resolution profile for this camera
    max_resolution: ResolutionProfile = .full_hd,
    
    /// Whether this camera has audio
    audio_enabled: bool = true,
    
    /// Whether to enable motion detection
    detect_enabled: bool = true,
    
    /// Whether this is an intercom station (gate/door)
    intercom_enabled: bool = false,
};

/// Resolution profiles for recording and live view
pub const ResolutionProfile = enum {
    /// 1920x1080 (Full HD)
    full_hd,
    /// 3840x2160 (4K UHD)
    uhd_4k,
    /// 7680x4320 (8K UHD)
    uhd_8k,
    
    pub fn getWidth(self: ResolutionProfile) u32 {
        return switch (self) {
            .full_hd => 1920,
            .uhd_4k => 3840,
            .uhd_8k => 7680,
        };
    }
    
    pub fn getHeight(self: ResolutionProfile) u32 {
        return switch (self) {
            .full_hd => 1080,
            .uhd_4k => 2160,
            .uhd_8k => 4320,
        };
    }
    
    pub fn getEstimatedBitrateMbps(self: ResolutionProfile) u32 {
        return switch (self) {
            .full_hd => 4,
            .uhd_4k => 25,
            .uhd_8k => 100,
        };
    }
};

/// Sensor zone configuration
pub const ZoneConfig = struct {
    id: []const u8,
    name: []const u8,
    zone_type: ZoneType,
    sensor_bindings: []const []const u8,
    bypass_enabled: bool = false,
    chime_enabled: bool = false,
    entry_delay_ms: ?u64 = null,
};

pub const ZoneType = enum {
    perimeter,
    interior,
    @"24h",
    fire,
    panic,
};

/// Alarm system state
pub const AlarmState = enum {
    disarmed,
    exit_delay,
    armed_away,
    armed_stay,
    entry_delay,
    alarm,
};

/// Alarm arming mode
pub const ArmingMode = enum {
    disarmed,
    armed_away,
    armed_stay,
};

/// Backup scope options
pub const BackupScope = enum {
    events_only,
    events_plus_rolling,
    full_continuous,
};

/// Site configuration
pub const SiteConfig = struct {
    site_name: []const u8,
    cameras: []const CameraConfig,
    zones: []const ZoneConfig,
    backup_scope: BackupScope,
    backup_retention_days: u32,
    backup_bandwidth_cap_mbps: u32,
    relay_url: []const u8,
};

test "resolution profile dimensions" {
    try std.testing.expectEqual(@as(u32, 1920), ResolutionProfile.full_hd.getWidth());
    try std.testing.expectEqual(@as(u32, 1080), ResolutionProfile.full_hd.getHeight());
    try std.testing.expectEqual(@as(u32, 3840), ResolutionProfile.uhd_4k.getWidth());
    try std.testing.expectEqual(@as(u32, 2160), ResolutionProfile.uhd_4k.getHeight());
    try std.testing.expectEqual(@as(u32, 7680), ResolutionProfile.uhd_8k.getWidth());
    try std.testing.expectEqual(@as(u32, 4320), ResolutionProfile.uhd_8k.getHeight());
}

test "resolution profile bitrate estimates" {
    try std.testing.expectEqual(@as(u32, 4), ResolutionProfile.full_hd.getEstimatedBitrateMbps());
    try std.testing.expectEqual(@as(u32, 25), ResolutionProfile.uhd_4k.getEstimatedBitrateMbps());
    try std.testing.expectEqual(@as(u32, 100), ResolutionProfile.uhd_8k.getEstimatedBitrateMbps());
}
