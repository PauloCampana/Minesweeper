const std = @import("std");
const rl = @import("raylib-zig/build.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "minesweeper",
        .root_source_file = b.path("src/main.zig"),
        .optimize = optimize,
        .target = target,
    });
    exe.linkLibC();
    exe.linkSystemLibrary("raylib");

    b.installArtifact(exe);

    const run_step = b.step("run", "Run minesweeper");
    const run_run = b.addRunArtifact(exe);
    run_step.dependOn(&run_run.step);
}
