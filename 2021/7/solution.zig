const std = @import("std");

pub fn costFunc(nums: []u16, guess: i32) u32 {
    var total: u32 = 0;
    for (nums) |num| {
        const diff = @intCast(u32, std.math.absInt(@as(i32, num) - guess) catch unreachable);
        total += (diff * (diff + 1));
    }
    return total / 2;
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var input = try std.os.mmap(null, try file.getEndPos(), std.os.PROT.READ, std.os.MAP.SHARED, file.handle, 0);
    defer std.os.munmap(input);

    var list = try std.BoundedArray(u16, 1000).init(0);
    var it = std.mem.tokenize(u8, input, ",\n");
    while (it.next()) |num| {
        var n = try std.fmt.parseUnsigned(u16, num, 10);
        list.appendAssumeCapacity(n);
    }

    // Part 1
    std.sort.sort(u16, list.slice(), {}, comptime std.sort.asc(u16));
    var median = list.get(try std.math.divCeil(usize, list.len, 2));

    var p1: usize = 0;
    for (list.slice()) |n| {
        var diff: usize = if (n > median) n - median else median - n;
        p1 += diff;
    }

    // Part 2
    var average = blk: {
        var sum: usize = 0;
        for (list.slice()) |n| {
            sum += n;
        } else break :blk @intCast(u16, sum / list.len);
    };

    var p2: usize = 0;
    for (list.slice()) |n| {
        const diff: usize = if (n > average) n - average else average - n;
        p2 += (diff * (diff + 1));
    }

    p2 /= 2;

    std.debug.print("Part 1: {}\nPart 2: {}\n", .{ p1, p2 });
}
