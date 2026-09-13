// Guardian configuration loading
const std = @import("std");
const types = @import("types.zig");

/// Load site configuration from /etc/guardian/site.json
pub fn loadSiteConfig(allocator: std.mem.Allocator) !types.SiteConfig {
    _ = allocator;
    // TODO: Implement JSON parsing from /etc/guardian/site.json
    return error.NotImplemented;
}

/// Validate site configuration
pub fn validateConfig(config: *const types.SiteConfig) !void {
    if (config.cameras.len == 0) {
        return error.NoCamerasConfigured;
    }
    
    if (config.zones.len == 0) {
        return error.NoZonesConfigured;
    }
    
    // Validate backup settings
    if (config.backup_retention_days == 0) {
        return error.InvalidRetention;
    }
}
