const std = @import("std");
const builtin = @import("builtin");

fn all(comptime T: type, items: []const T, f: fn (v: T) bool) bool {
    for (items) |item| {
        if (!f(item)) return false;
    }

    return true;
}

const CaveMap = struct {
    map: std.StringHashMap(std.ArrayList([]const u8)),
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !Self {
        return Self{
            .allocator = allocator,
            .map = std.StringHashMap(std.ArrayList([]const u8)).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        var it = self.map.valueIterator();
        while (it.next()) |v| v.deinit();
        self.map.deinit();
    }

    pub fn addConnection(self: *Self, src: []const u8, dst: []const u8) !void {
        var result = try self.map.getOrPut(src);
        if (!result.found_existing) {
            result.value_ptr.* = std.ArrayList([]const u8).init(self.map.allocator);
        }

        try result.value_ptr.append(dst);
    }

    pub fn interator(self: *Self) @TypeOf(Self.map).ValueIterator {
        return self.map.iterator();
    }

    pub fn parseLine(self: *Self, line: []const u8) !void {
        var it = std.mem.split(u8, line, "-");
        const src = it.next().?;
        const dst = it.next().?;

        if (!std.mem.eql(u8, dst, "start")) {
            try self.addConnection(src, dst);
        }

        if (!std.mem.eql(u8, src, "start") and !std.mem.eql(u8, dst, "end")) {
            try self.addConnection(dst, src);
        }
    }

    pub fn findPaths(self: Self, start: []const u8, visited: *std.StringHashMap(u2), can_visit_twice: bool) std.mem.Allocator.Error!u32 {
        if (std.mem.eql(u8, start, "end")) {
            return 1;
        }

        var num_paths: u32 = 0;
        for (self.map.get(start).?.items) |next| {
            var visit_twice = can_visit_twice;
            const is_lower = all(u8, next, std.ascii.isLower);
            if (is_lower) {
                const times_visited = visited.get(next) orelse 0;
                if (times_visited > @boolToInt(can_visit_twice)) {
                    continue;
                }

                if (times_visited > 0) visit_twice = false;
            }

            if (is_lower) (try visited.getOrPutValue(next, 0)).value_ptr.* += 1;
            num_paths += try self.findPaths(next, visited, visit_twice);
            if (is_lower) visited.getPtr(next).?.* -= 1;
        }

        return num_paths;
    }
};

test "CaveMap.parseLine" {
    var cave_map = try CaveMap.init(std.testing.allocator);
    defer cave_map.deinit();

    try cave_map.parseLine("start-A");
    try cave_map.parseLine("start-b");
    try cave_map.parseLine("A-c");
    try cave_map.parseLine("A-b");
    try cave_map.parseLine("b-d");
    try cave_map.parseLine("A-end");
    try cave_map.parseLine("b-end");

    var it = cave_map.map.iterator();
    while (it.next()) |entry| {
        std.debug.print("{s} = {s}\n", .{ entry.key_ptr.*, entry.value_ptr.items });
    }
}

test "CaveMap.findPaths" {
    var cave_map = try CaveMap.init(std.testing.allocator);
    defer cave_map.deinit();

    try cave_map.parseLine("start-A");
    try cave_map.parseLine("start-b");
    try cave_map.parseLine("A-c");
    try cave_map.parseLine("A-b");
    try cave_map.parseLine("b-d");
    try cave_map.parseLine("A-end");
    try cave_map.parseLine("b-end");

    var visited = std.StringHashMap(u2).init(std.testing.allocator);
    defer visited.deinit();

    std.debug.print("{}\n", .{try cave_map.findPaths("start", &visited)});
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf = try std.os.mmap(null, try file.getEndPos(), std.os.PROT.READ, std.os.MAP.SHARED, file.handle, 0);
    defer std.os.munmap(buf);

    var cave_map = try CaveMap.init(allocator);
    defer cave_map.deinit();

    var lines = std.mem.tokenize(u8, buf, "\n");
    while (lines.next()) |line| {
        try cave_map.parseLine(line);
    }

    var visited = std.StringHashMap(u2).init(allocator);
    defer visited.deinit();

    // const p1 = try cave_map.findPaths("start", &visited, false);
    const p2 = try cave_map.findPaths("start", &visited, true);
    std.debug.print("Part 1: {}\nPart 2: {}\n", .{ 0, p2 });
}
