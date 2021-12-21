const std = @import("std");

const Digit = packed struct {
    a: u1 = 0,
    b: u1 = 0,
    c: u1 = 0,
    d: u1 = 0,
    e: u1 = 0,
    f: u1 = 0,
    g: u1 = 0,

    const letters = "abcdefg";

    pub fn from(str: []const u8) Digit {
        var digit = Digit{};
        for (str) |c| {
            inline for (letters) |l| {
                if (l == c) @field(digit, &[_]u8{l}) = 1;
            }
        }
        return digit;
    }

    pub fn diff(self: Digit, other: Digit) Digit {
        var a = @bitCast(u7, self);
        var b = @bitCast(u7, other);
        var c = a ^ b;
        return @bitCast(Digit, c);
    }

    pub fn distance(self: Digit, other: Digit) u3 {
        return @popCount(u7, @bitCast(u7, self.diff(other)));
    }

    pub fn contains(self: Digit, other: Digit) bool {
        var a = @bitCast(u7, self);
        var b = @bitCast(u7, other);
        return a & b == b;
    }
};

fn solveLine(line: []const u8, num_unique: *usize) !u32 {
    var it = std.mem.split(u8, line, " | ");
    var left = it.next() orelse unreachable;
    var right = it.next() orelse unreachable;

    var one = Digit{};
    var four = Digit{};
    var seven = Digit{};
    var eight = Digit{};

    var inputs_it = std.mem.tokenize(u8, left, " ");
    while (inputs_it.next()) |s| {
        switch (s.len) {
            2 => one = Digit.from(s),
            3 => seven = Digit.from(s),
            4 => four = Digit.from(s),
            7 => eight = Digit.from(s),
            else => {},
        }
    }

    var result: u32 = 0;
    var i: u32 = 1000;
    var outputs_it = std.mem.tokenize(u8, right, " ");
    while (outputs_it.next()) |s| : (i /= 10) {
        // Part 1: count number of digits with unique number of segments
        switch (s.len) {
            2, 3, 4, 7 => num_unique.* += 1,
            else => {},
        }

        const d = Digit.from(s);
        const digit: u4 = switch (s.len) {
            2 => 1,
            3 => 7,
            4 => 4,
            5 => if (d.contains(seven))
                3
            else if (d.distance(four) == 5)
                // Type cast needed here: https://github.com/ziglang/zig/issues/5557
                @as(u4, 2)
            else
                5,
            6 => if (d.contains(four))
                9
            else if (d.contains(seven))
                // Type cast needed here: https://github.com/ziglang/zig/issues/5557
                @as(u4, 0)
            else
                6,
            7 => 8,
            else => unreachable,
        };
        result += i * digit;
    }

    return result;
}

pub fn main() !void {
    const input = @embedFile("input.txt");

    var p1: usize = 0;
    var p2: usize = 0;
    var line_it = std.mem.tokenize(u8, input, "\n");
    while (line_it.next()) |line| {
        p2 += try solveLine(line, &p1);
    }

    std.debug.print("Part 1: {}\nPart 2: {}\n", .{ p1, p2 });
}
