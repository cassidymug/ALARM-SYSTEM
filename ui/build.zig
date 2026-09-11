const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "guardian-ui",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const common_mod = b.addModule("guardian-common", .{
        .root_source_file = b.path("../services/common/src/lib.zig"),
    });
    exe.root_module.addImport("guardian-common", common_mod);

    // Link SDL2
    exe.linkSystemLibrary("SDL2");
    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run guardian-ui");
    run_step.dependOn(&run_cmd.step);
}
