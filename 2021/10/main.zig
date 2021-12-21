const std = @import("std");

const pairs = init: {
    var buf: [127]u8 = undefined;

    buf[')'] = '(';
    buf[']'] = '[';
    buf['}'] = '{';
    buf['>'] = '<';

    break :init buf;
};

const Result = union(enum) {
    corrupted: u32,
    incomplete: u64,
};

fn parseLine(line: []const u8) Result {
    var stack = std.BoundedArray(u8, 200).init(0) catch unreachable;

    for (line) |c| {
        if (std.mem.indexOfScalar(u8, ")]}>", c)) |_| {
            if (stack.pop() != pairs[c]) {
                return Result{
                    .corrupted = switch (c) {
                        ')' => 3,
                        ']' => 57,
                        '}' => 1197,
                        '>' => 25137,
                        else => unreachable,
                    },
                };
            }
        } else {
            stack.appendAssumeCapacity(c);
        }
    }

    var score: u64 = 0;
    while (stack.popOrNull()) |item| {
        score = 5 * score + @as(u64, switch (item) {
            '(' => 1,
            '[' => 2,
            '{' => 3,
            '<' => 4,
            else => unreachable,
        });
    }

    return Result{ .incomplete = score };
}

pub fn main() !void {
    const input = @embedFile("input.txt");

    var p1: u32 = 0;
    var scores = try std.BoundedArray(u64, 100).init(0);
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        switch (parseLine(line)) {
            .corrupted => |score| p1 += score,
            .incomplete => |score| scores.appendAssumeCapacity(score),
        }
    }

    std.sort.sort(u64, scores.slice(), {}, comptime std.sort.asc(u64));
    const p2 = scores.get(@divFloor(scores.len, 2));

    std.debug.print("Part 1: {}\nPart 2: {}\n", .{ p1, p2 });
}
