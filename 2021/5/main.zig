const std = @import("std");

const Point = struct {
    x: u16,
    y: u16,

    const Self = @This();

    pub fn parse(s: []const u8) !Self {
        var it = std.mem.split(u8, s, ",");
        var x = if (it.next()) |x| try std.fmt.parseUnsigned(u16, x, 10) else return error.ParseError;
        var y = if (it.next()) |y| try std.fmt.parseUnsigned(u16, y, 10) else return error.ParseError;

        return Self{ .x = x, .y = y };
    }

    pub fn eql(self: Self, other: Self) bool {
        return self.x == other.x and self.y == other.y;
    }
};

const Path = struct {
    start: Point,
    end: Point,

    const Self = @This();

    pub fn readFrom(allocator: std.mem.Allocator, data: []const u8) ![]Self {
        var paths = std.ArrayList(Path).init(allocator);

        var line_it = std.mem.tokenize(u8, data, "\n");
        while (line_it.next()) |line| {
            var it = std.mem.split(u8, line, " -> ");
            const start = try Point.parse(it.next() orelse unreachable);
            const end = try Point.parse(it.next() orelse unreachable);
            try paths.append(.{
                .start = start,
                .end = end,
            });
        }

        return paths.toOwnedSlice();
    }

    pub fn isStraight(self: Self) bool {
        return self.start.x == self.end.x or
            self.start.y == self.end.y;
    }
};

const Map = struct {
    data: std.AutoHashMap(Point, u8),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{ .data = std.AutoHashMap(Point, u8).init(allocator) };
    }

    pub fn deinit(self: *Self) void {
        self.data.deinit();
    }

    pub fn traverse(self: *Self, path: Path) !void {
        var start = path.start;
        const end = path.end;

        while (!start.eql(end)) {
            try self.visit(start);
            if (start.x < end.x) {
                start.x += 1;
            } else if (start.x > end.x) {
                start.x -= 1;
            }

            if (start.y < end.y) {
                start.y += 1;
            } else if (start.y > end.y) {
                start.y -= 1;
            }
        }

        try self.visit(end);
    }

    fn visit(self: *Self, point: Point) !void {
        var entry = try self.data.getOrPutValue(point, 0);
        entry.value_ptr.* += 1;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    var map = Map.init(allocator);
    defer map.deinit();

    const input = @embedFile("input.txt");

    const paths = try Path.readFrom(allocator, input);
    defer allocator.free(paths);

    for (paths) |path| {
        // Uncomment for part 1
        // if (path.isStraight())
        try map.traverse(path);
    }

    var num_overlaps: usize = 0;
    var it = map.data.valueIterator();
    while (it.next()) |val| {
        if (val.* > 1) num_overlaps += 1;
    }

    std.debug.print("Number of overlaps: {d}\n", .{num_overlaps});
}
