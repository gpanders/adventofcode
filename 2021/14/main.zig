const std = @import("std");

const StringCountMap = struct {
    hash_map: InnerMap,

    const InnerMap = std.StringHashMap(u64);

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .hash_map = InnerMap.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        var it = self.hash_map.keyIterator();
        while (it.next()) |key| {
            self.hash_map.allocator.free(key.*);
        }
        self.hash_map.deinit();
    }

    pub fn inc(self: *Self, s: []const u8, count: u64) !void {
        const get_or_put = try self.hash_map.getOrPut(s);
        if (!get_or_put.found_existing) {
            get_or_put.key_ptr.* = try self.hash_map.allocator.dupe(u8, s);
            get_or_put.value_ptr.* = 0;
        }
        get_or_put.value_ptr.* += count;
    }

    pub fn dec(self: *Self, s: []const u8, count: u64) !void {
        if (self.hash_map.getPtr(s)) |v| {
            if (count <= v.*) {
                v.* -= count;
            } else {
                return error.Overflow;
            }
        } else {
            return error.MissingKey;
        }
    }

    pub fn iterator(self: *Self) InnerMap.Iterator {
        return self.hash_map.iterator();
    }

    pub fn clone(self: *Self) !Self {
        var hash_map = try self.hash_map.clone();
        var it = hash_map.keyIterator();
        while (it.next()) |key| {
            key.* = try self.hash_map.allocator.dupe(u8, key.*);
        }
        return Self{ .hash_map = hash_map };
    }

    pub fn get(self: *Self, s: []const u8) ?u64 {
        return self.hash_map.get(s);
    }
};

fn step(counts: *StringCountMap, rules: std.BufMap) !void {
    var clone = try counts.clone();
    defer clone.deinit();

    var it = clone.iterator();
    while (it.next()) |entry| {
        const pair = entry.key_ptr.*;
        const num_pairs = entry.value_ptr.*;
        const c = rules.get(pair).?;
        const first_pair = &[_]u8{ pair[0], c[0] };
        const second_pair = &[_]u8{ c[0], pair[1] };
        try counts.dec(pair, num_pairs);
        try counts.inc(first_pair, num_pairs);
        try counts.inc(second_pair, num_pairs);
    }
}

pub fn solve(allocator: std.mem.Allocator, template: []const u8, rules: std.BufMap, steps: usize) !u64 {
    var counts = StringCountMap.init(allocator);
    defer counts.deinit();

    for (template[0 .. template.len - 1]) |_, i| {
        var s = template[i .. i + 2];
        try counts.inc(s, 1);
    }

    var i: usize = 0;
    while (i < steps) : (i += 1) {
        try step(&counts, rules);
    }

    var single_char_counts = std.AutoArrayHashMap(u8, u64).init(allocator);
    defer single_char_counts.deinit();

    try single_char_counts.put(template[template.len - 1], 1);

    var it = counts.iterator();
    while (it.next()) |entry| {
        const c = entry.key_ptr.*[0];
        (try single_char_counts.getOrPutValue(c, 0)).value_ptr.* += entry.value_ptr.*;
    }

    var most_common: u64 = 0;
    var least_common: u64 = std.math.maxInt(u64);
    var it2 = single_char_counts.iterator();
    while (it2.next()) |entry| {
        const count = entry.value_ptr.*;
        if (count > most_common) {
            most_common = count;
        }

        if (count < least_common) {
            least_common = count;
        }
    }

    return most_common - least_common;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var input = try std.os.mmap(null, try file.getEndPos(), std.os.PROT.READ, std.os.MAP.SHARED, file.handle, 0);
    defer std.os.munmap(input);

    var rules = std.BufMap.init(allocator);
    defer rules.deinit();

    var lines = std.mem.tokenize(u8, input, "\n");
    var template = lines.next().?;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var it = std.mem.split(u8, line, " -> ");
        try rules.put(it.next().?, it.next().?);
    }

    // std.debug.print("Part 1: {}\n", .{solve(allocator, template, rules, 10)});
    std.debug.print("Part 2: {}\n", .{solve(allocator, template, rules, 40)});
}
