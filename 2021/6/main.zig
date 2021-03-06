const std = @import("std");

pub fn main() !void {
    // counts is a mapping from "number of days left to reproduce" to "number of fish"
    var counts = [_]u64{0} ** 9;

    const input = @embedFile("input.txt");

    var it = std.mem.tokenize(u8, input, ",\n");
    while (it.next()) |num| {
        var n = try std.fmt.parseUnsigned(u4, num, 10);
        counts[n] += 1;
    }

    var day: usize = 0;
    while (day < 256) : (day += 1) {
        var new = counts[0];
        for (counts[1..]) |c, i| counts[i] = c;
        counts[6] += new;
        counts[8] = new;
    }

    var sum: usize = 0;
    for (counts) |c| sum += c;
    std.debug.print("Total fish: {d}\n", .{sum});
}
