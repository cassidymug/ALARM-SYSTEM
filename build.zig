const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Build all services and UI
    const services = [_][]const u8{
        "common",
        "recorder",
        "detect",
        "alarm",
        "sensors",
        "api",
        "intercom",
        "gateway",
        "backup",
        "setup",
    };

    inline for (services) |service| {
        const service_dep = b.dependency(service, .{
            .target = target,
            .optimize = optimize,
        });
        
        // For services other than common, add install step
        if (!std.mem.eql(u8, service, "common")) {
            const exe = service_dep.artifact(b.fmt("guardian-{s}", .{service}));
            b.installArtifact(exe);
        }
    }

    // Build UI
    const ui_dep = b.dependency("ui", .{
        .target = target,
        .optimize = optimize,
    });
    const ui_exe = ui_dep.artifact("guardian-ui");
    b.installArtifact(ui_exe);

    // Test step runs all tests
    const test_step = b.step("test", "Run all tests");
    
    inline for (services) |service| {
        const service_dep = b.dependency(service, .{
            .target = target,
            .optimize = optimize,
        });
        const service_tests = service_dep.module(b.fmt("{s}-tests", .{service}));
        test_step.dependOn(&service_tests.step);
    }
}
