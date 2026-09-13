// Guardian setup daemon - first-boot wizard and configuration
const std = @import("std");
const common = @import("guardian-common");

const log = common.logging;
const types = common.types;

const SERVICE_NAME = "setup";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    log.info(SERVICE_NAME, "Guardian setup wizard", .{});

    // TODO: Interactive wizard for:
    // - Network configuration
    // - Camera discovery and configuration
    // - Zone setup
    // - Arming defaults
    // - Relay enrollment
    // - Backup scope selection (1: events only, 2: events + rolling, 3: full)
    // - Retention and bandwidth cap
    // - Recovery key generation and display

    // TODO: Write to /etc/guardian/site.json
    // TODO: Generate /etc/guardian/certs/ for mTLS
    // TODO: Enable systemd units

    log.info(SERVICE_NAME, "Setup wizard stub - configuration not implemented", .{});
    _ = allocator;
}
