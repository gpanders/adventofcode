const std = @import("std");

const Map = struct {
    data: [10][10]u4 = [_][10]u4{[_]u4{0} ** 10} ** 10,
    flashes: u32 = 0,

    /// Increment the number at (row, col) if it is greater than 0. A value of
    /// 0 indicates this position has already flashed this step.
    fn inc(self: *Map, row: usize, col: usize) void {
        var v = &self.data[row][col];
        if (v.* > 0 and v.* < 10) {
            v.* += 1;
        }

        if (v.* == 10) {
            self.flash(row, col);
        }
    }

    fn flash(self: *Map, row: usize, col: usize) void {
        self.data[row][col] = 0;
        self.flashes += 1;

        if (row > 0) {
            if (col > 0) self.inc(row - 1, col - 1);
            self.inc(row - 1, col);
            if (col < 9) self.inc(row - 1, col + 1);
        }

        if (col > 0) self.inc(row, col - 1);
        if (col < 9) self.inc(row, col + 1);

        if (row < 9) {
            if (col > 0) self.inc(row + 1, col - 1);
            self.inc(row + 1, col);
            if (col < 9) self.inc(row + 1, col + 1);
        }
    }

    pub fn step(self: *Map) bool {
        for (self.data) |*row| {
            for (row) |*v| {
                v.* += 1;
            }
        }

        for (self.data) |_, row| {
            for (self.data[row]) |v, col| {
                if (v >= 10) {
                    self.flash(row, col);
                }
            }
        }

        outer: for (self.data) |row| {
            for (row) |v| {
                if (v != 0) {
                    break :outer;
                }
            }
        } else {
            return true;
        }

        return false;
    }

    pub fn print(self: Map) void {
        var row: usize = 0;
        while (row < 10) : (row += 1) {
            var col: usize = 0;
            while (col < 10) : (col += 1) {
                const v = self.data[row][col];
                if (v == 0) {
                    std.debug.print("\x1b[77;1m{}\x1b[0m", .{v});
                } else {
                    std.debug.print("{}", .{v});
                }
            }
            std.debug.print("\n", .{});
        }
    }
};

pub fn main() !void {
    const input = @embedFile("input.txt");

    var map = Map{};

    var row: usize = 0;
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| : (row += 1) {
        for (line) |c, col| {
            map.data[row][col] = try std.fmt.parseUnsigned(u4, &[_]u8{c}, 10);
        }
    }

    var p1: u32 = 0;
    var i: usize = 0;
    while (true) : (i += 1) {
        // std.debug.print("Step {}\n", .{i});
        // map.print();
        if (i == 100) p1 = map.flashes;
        if (map.step()) break;
    }

    std.debug.print("Part 1: {}\nPart 2: {}\n", .{ p1, i + 1 });
}
