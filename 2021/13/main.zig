const std = @import("std");

const Point = struct {
    x: u16,
    y: u16,
};

const Fold = struct {
    axis: enum(u1) { x, y },
    pos: u16,
};

fn fold(points: *std.AutoArrayHashMap(Point, void), fld: Fold) !void {
    var keys = try points.allocator.dupe(Point, points.keys());
    defer points.allocator.free(keys);

    for (keys) |point| {
        switch (fld.axis) {
            .x => if (point.x > fld.pos) {
                _ = points.swapRemove(point);
                points.putAssumeCapacity(.{ .x = 2 * fld.pos - point.x, .y = point.y }, {});
            },
            .y => if (point.y > fld.pos) {
                _ = points.swapRemove(point);
                points.putAssumeCapacity(.{ .x = point.x, .y = 2 * fld.pos - point.y }, {});
            },
        }
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    const input = @embedFile("input.txt");

    var folds = try std.BoundedArray(Fold, 12).init(0);

    var points = std.AutoArrayHashMap(Point, void).init(allocator);
    defer points.deinit();

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        if (std.mem.startsWith(u8, line, "fold along ")) {
            var it = std.mem.split(u8, line["fold along ".len..], "=");
            const dir = it.next().?;
            const pos = try std.fmt.parseUnsigned(u16, it.next().?, 10);
            folds.appendAssumeCapacity(.{ .pos = pos, .axis = switch (dir[0]) {
                'x' => .x,
                'y' => .y,
                else => unreachable,
            } });
        } else {
            var it = std.mem.split(u8, line, ",");
            const x = try std.fmt.parseUnsigned(u16, it.next().?, 10);
            const y = try std.fmt.parseUnsigned(u16, it.next().?, 10);
            try points.put(.{ .x = x, .y = y }, {});
        }
    }

    for (folds.slice()) |fld, i| {
        try fold(&points, fld);
        if (i == 0) std.debug.print("Part 1: {}\n", .{points.keys().len});
    }

    std.debug.print("Part 2:\n", .{});
    var row: u16 = 0;
    while (row < 6) : (row += 1) {
        var col: u16 = 0;
        while (col < 40) : (col += 1) {
            if (points.get(.{ .y = row, .x = col })) |_| {
                std.debug.print("#", .{});
            } else {
                std.debug.print(" ", .{});
            }
        }
        std.debug.print("\n", .{});
    }
}
