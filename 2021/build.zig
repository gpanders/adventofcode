const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    comptime var i: usize = 1;
    inline while (i <= 25) : (i += 1) {
        const name = std.fmt.comptimePrint("{d}", .{i});
        if (std.fs.cwd().openDir(name, .{})) |dir| {
            if (dir.access("main.zig", .{})) {
                const exe = b.addExecutable(name, try dir.realpathAlloc(b.allocator, "main.zig"));
                exe.setTarget(target);
                exe.setBuildMode(mode);
                exe.install();
            } else |err| switch (err) {
                error.FileNotFound => {},
                else => return err,
            }
        } else |err| switch (err) {
            error.FileNotFound => {},
            else => return err,
        }
    }
}
