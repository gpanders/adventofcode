const std = @import("std");

const Point = struct {
    row: u16,
    col: u16,

    pub fn eql(self: Point, other: Point) bool {
        return self.row == other.row and self.col == other.col;
    }

    pub fn neighbors(self: Point, allocator: std.mem.Allocator, size: u16) ![]Point {
        var neighbs = std.ArrayList(Point).init(allocator);

        if (self.row > 0) {
            try neighbs.append(.{ .row = self.row - 1, .col = self.col });
        }

        if (self.col < size - 1) {
            try neighbs.append(.{ .row = self.row, .col = self.col + 1 });
        }

        if (self.row < size - 1) {
            try neighbs.append(.{ .row = self.row + 1, .col = self.col });
        }

        if (self.col > 0) {
            try neighbs.append(.{ .row = self.row, .col = self.col - 1 });
        }

        return neighbs.toOwnedSlice();
    }
};

const Cost = u32;

const QueueItem = struct {
    point: Point,
    cost: Cost,
};

fn heuristic(a: Point, b: Point) Cost {
    const x_dist = if (a.col > b.col) a.col - b.col else b.col - a.col;
    const y_dist = if (a.row > b.row) a.row - b.row else b.row - a.row;
    return x_dist + y_dist;
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var input = try std.os.mmap(null, try file.getEndPos(), std.os.PROT.READ, std.os.MAP.SHARED, file.handle, 0);
    defer std.os.munmap(input);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit()) std.debug.print("Memory leak detected\n", .{});

    var allocator = gpa.allocator();

    var weights = std.AutoHashMap(Point, u4).init(allocator);
    defer weights.deinit();

    var lines = std.mem.tokenize(u8, input, "\n");
    var grid_size: u16 = 0;
    {
        var row: u16 = 0;
        while (lines.next()) |line| : (row += 1) {
            grid_size = @intCast(u16, line.len);
            for (line) |c, col| {
                const weight = try std.fmt.parseUnsigned(u4, &[_]u8{c}, 10);
                const point = Point{ .row = row, .col = @intCast(u16, col) };
                try weights.put(point, weight);

                // Part 2
                var j: u4 = 0;
                while (j < 5) : (j += 1) {
                    var k: u4 = 0;
                    while (k < 5) : (k += 1) {
                        if (j == 0 and k == 0) continue;

                        var new_point = Point{
                            .row = row + j * grid_size,
                            .col = @intCast(u16, col + k * grid_size),
                        };
                        var new_weight: u4 = @intCast(u4, ((@as(u8, weight) + j + k - 1) % 9) + 1);
                        try weights.put(new_point, new_weight);
                    }
                }
            }
        }
    }

    // Part 2
    grid_size *= 5;

    var frontier = std.PriorityQueue(QueueItem, struct {
        fn compare(a: QueueItem, b: QueueItem) std.math.Order {
            return std.math.order(a.cost, b.cost);
        }
    }.compare).init(allocator);
    defer frontier.deinit();

    var came_from = std.AutoHashMap(Point, Point).init(allocator);
    defer came_from.deinit();

    var cost_so_far = std.AutoHashMap(Point, Cost).init(allocator);
    defer cost_so_far.deinit();

    const start = Point{ .row = 0, .col = 0 };
    const goal = Point{ .row = grid_size - 1, .col = grid_size - 1 };

    try frontier.add(.{ .point = start, .cost = 0 });
    try cost_so_far.put(start, 0);

    while (frontier.removeOrNull()) |item| {
        const current = item.point;
        if (current.eql(goal)) {
            break;
        }

        const neighbors = try current.neighbors(allocator, grid_size);
        defer allocator.free(neighbors);
        for (neighbors) |next| {
            const new_cost = cost_so_far.get(current).? + weights.get(next).?;
            var gop = try cost_so_far.getOrPut(next);
            if (!gop.found_existing or new_cost < gop.value_ptr.*) {
                gop.value_ptr.* = new_cost;
                try frontier.add(.{ .point = next, .cost = new_cost + heuristic(goal, next) });
                try came_from.put(next, current);
            }
        }
    }

    var total_risk: usize = weights.get(goal).?;
    var p = goal;
    while (came_from.get(p)) |prev| {
        total_risk += weights.get(prev).?;
        p = prev;
    }

    total_risk -= weights.get(start).?;

    std.debug.print("{}\n", .{total_risk});
}
