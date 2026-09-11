// Guardian backup daemon - client-side encrypt and upload offsite
const std = @import("std");
const common = @import("guardian-common");

const log = common.logging;
const types = common.types;
const EventBus = common.event_bus.EventBus;

const SERVICE_NAME = "backup";

pub const BackupManager = struct {
    allocator: std.mem.Allocator,
    event_bus: *EventBus,
    config: types.SiteConfig,
    running: std.atomic.Value(bool),
    staging_dir: []const u8,

    pub fn init(allocator: std.mem.Allocator, config: types.SiteConfig, event_bus: *EventBus, staging_dir: []const u8) !BackupManager {
        return .{
            .allocator = allocator,
            .event_bus = event_bus,
            .config = config,
            .running = std.atomic.Value(bool).init(false),
            .staging_dir = staging_dir,
        };
    }

    pub fn deinit(self: *BackupManager) void {
        _ = self;
    }

    pub fn start(self: *BackupManager) !void {
        log.info(SERVICE_NAME, "Starting backup manager, scope: {s}", .{@tagName(self.config.backup_scope)});
        log.info(SERVICE_NAME, "Retention: {d} days, bandwidth cap: {d} Mbps", .{
            self.config.backup_retention_days,
            self.config.backup_bandwidth_cap_mbps,
        });
        self.running.store(true, .seq_cst);

        // TODO: Subscribe to recording segment events
        // TODO: Encrypt and upload based on backup scope
        // TODO: Respect bandwidth cap

        while (self.running.load(.seq_cst)) {
            std.time.sleep(60 * std.time.ns_per_s); // Check every minute
        }
    }

    pub fn stop(self: *BackupManager) void {
        log.info(SERVICE_NAME, "Stopping backup manager", .{});
        self.running.store(false, .seq_cst);
    }

    fn encryptFile(self: *BackupManager, source_path: []const u8) ![]const u8 {
        // TODO: age or libsodium encryption
        log.debug(SERVICE_NAME, "Encrypting {s}", .{source_path});
        _ = self;
        return source_path;
    }

    fn uploadToHetzner(self: *BackupManager, encrypted_path: []const u8) !void {
        // TODO: S3-compatible API upload to Object Storage
        log.debug(SERVICE_NAME, "Uploading {s}", .{encrypted_path});
        _ = self;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.info(SERVICE_NAME, "Guardian backup daemon starting", .{});

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

    var backup = try BackupManager.init(allocator, config, &event_bus, "/srv/guardian/backup-staging");
    defer backup.deinit();

    try backup.start();
}
