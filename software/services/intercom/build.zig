const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "guardian-intercom",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const common_mod = b.addModule("guardian-common", .{
        .root_source_file = b.path("../common/src/lib.zig"),
    });
    exe.root_module.addImport("guardian-common", common_mod);

    b.installArtifact(exe);
}
