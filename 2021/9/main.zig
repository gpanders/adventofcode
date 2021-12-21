const std = @import("std");

const Point = struct {
    row: u8,
    col: u8,
};

const Map = struct {
    const MapEntry = struct {
        height: u4,
        basin: bool = false,
    };

    data: std.AutoArrayHashMap(Point, MapEntry),

    pub fn init(allocator: std.mem.Allocator) Map {
        return Map{
            .data = std.AutoArrayHashMap(Point, MapEntry).init(allocator),
        };
    }

    pub fn deinit(self: *Map) void {
        self.data.deinit();
    }

    pub fn put(self: *Map, point: Point, height: u4) !void {
        try self.data.put(point, .{ .height = height });
    }

    fn getHeight(self: Map, row: u8, col: u8) u4 {
        return if (self.data.get(.{ .row = row, .col = col })) |v|
            v.height
        else
            std.math.maxInt(u4);
    }

    pub fn traverse(self: *Map, point: Point) u32 {
        if (self.data.getPtr(point)) |entry| {
            if (entry.height == 9 or entry.basin) {
                return 0;
            }

            entry.basin = true;
        } else {
            return 0;
        }

        var sum: u32 = 1;

        if (point.row > 0) sum += self.traverse(.{ .row = point.row - 1, .col = point.col });
        if (point.col > 0) sum += self.traverse(.{ .row = point.row, .col = point.col - 1 });
        sum += self.traverse(.{ .row = point.row + 1, .col = point.col });
        sum += self.traverse(.{ .row = point.row, .col = point.col + 1 });

        return sum;
    }

    pub fn isLowpoint(self: *Map, point: Point, height: u4) bool {
        const u = if (point.row > 0) self.getHeight(point.row - 1, point.col) else 9;
        const l = if (point.col > 0) self.getHeight(point.row, point.col - 1) else 9;
        const r = self.getHeight(point.row, point.col + 1);
        const d = self.getHeight(point.row + 1, point.col);

        return height < u and height < r and height < d and height < l;
    }
};

pub fn main() !void {
    const input = @embedFile("input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    var map = Map.init(allocator);
    defer map.deinit();

    var lines = std.mem.tokenize(u8, input, "\n");
    var row: u8 = 0;
    while (lines.next()) |line| : (row += 1) {
        for (line) |c, i| {
            const height = try std.fmt.parseUnsigned(u4, &[_]u8{c}, 10);
            const point = Point{ .row = row, .col = @intCast(u8, i) };
            try map.put(point, height);
        }
    }

    var p1: usize = 0;
    var it = map.data.iterator();
    while (it.next()) |entry| {
        const point = entry.key_ptr.*;
        const height = entry.value_ptr.height;
        if (map.isLowpoint(point, height)) {
            p1 += height + 1;
        }
    }

    var basin_sizes = [_]u32{0} ** 3;
    it.reset();
    while (it.next()) |entry| {
        const point = entry.key_ptr.*;
        const height = entry.value_ptr.height;
        const basin = entry.value_ptr.basin;
        if (height == 9 or basin) {
            continue;
        }

        const size = map.traverse(point);
        if (std.sort.argMin(u32, basin_sizes[0..], {}, comptime std.sort.asc(u32))) |i| {
            if (size > basin_sizes[i]) {
                basin_sizes[i] = size;
            }
        }
    }

    var p2: u32 = basin_sizes[0];
    for (basin_sizes[1..]) |size| p2 *= size;

    std.debug.print("Part 1: {}\nPart 2: {}\n", .{ p1, p2 });
}
