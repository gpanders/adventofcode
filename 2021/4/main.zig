const std = @import("std");

const max_bytes = std.math.maxInt(usize);

const BingoSquare = struct {
    data: [size][size]u8 = undefined,
    winning_turn: usize = 0,
    score: u64 = 0,

    const size = 5;

    const Self = @This();

    pub fn readFrom(allocator: std.mem.Allocator, file: std.fs.File, draw_index_map: std.AutoHashMap(u8, usize)) !Self {
        const reader = file.reader();

        var self = Self{};

        try reader.skipUntilDelimiterOrEof('\n');

        var max_col_index = [_]usize{0} ** size;
        var max_row_index = [_]usize{0} ** size;

        for (self.data) |*row, i| {
            var line = try reader.readUntilDelimiterAlloc(allocator, '\n', max_bytes);
            defer allocator.free(line);

            var row_index: usize = 0;
            var it = std.mem.tokenize(u8, line, " ");
            var col: usize = 0;
            while (it.next()) |ch| : (col += 1) {
                const num = try std.fmt.parseUnsigned(u8, ch, 10);
                row[col] = num;

                const index = draw_index_map.get(num) orelse unreachable;
                if (index > row_index) {
                    row_index = index;
                }

                if (index > max_col_index[col]) {
                    max_col_index[col] = index;
                }
            }

            max_row_index[i] = row_index;
        }

        var min_row_index = max_row_index[0];
        for (max_row_index[1..]) |r| {
            if (r < min_row_index) {
                min_row_index = r;
            }
        }

        var min_col_index = max_col_index[0];
        for (max_col_index[1..]) |c| {
            if (c < min_col_index) {
                min_col_index = c;
            }
        }

        self.winning_turn = @minimum(min_col_index, min_row_index);

        // The score is calculated by summing the numbers that have not yet been marked. Unmarked
        // numbers are those whose index is greater than the winning turn.
        for (self.data) |row| {
            for (row) |col| {
                const i = draw_index_map.get(col) orelse unreachable;
                if (i > self.winning_turn) {
                    self.score += col;
                }
            }
        }

        return self;
    }

    pub fn calculateScore(self: Self, draw_list: []u8) u64 {
        return draw_list[self.winning_turn] * self.score;
    }
};

pub fn readDrawList(allocator: std.mem.Allocator, in: std.fs.File) ![]u8 {
    var draw_list = std.ArrayList(u8).init(allocator);

    var line = try in.reader().readUntilDelimiterAlloc(allocator, '\n', max_bytes);
    defer allocator.free(line);

    var it = std.mem.split(u8, line, ",");
    while (it.next()) |n| {
        try draw_list.append(try std.fmt.parseUnsigned(u8, n, 10));
    }

    return draw_list.toOwnedSlice();
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    const input_file = try std.fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    var draw_list = try readDrawList(allocator, input_file);
    defer allocator.free(draw_list);

    // Map number to index in draw list
    var draw_index_map = std.AutoHashMap(u8, usize).init(allocator);
    defer draw_index_map.deinit();
    for (draw_list) |n, i| try draw_index_map.put(n, i);

    var squares = std.ArrayList(BingoSquare).init(allocator);
    defer squares.deinit();

    while (BingoSquare.readFrom(allocator, input_file, draw_index_map)) |square| {
        try squares.append(square);
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    const cmp = struct {
        fn cmp(_: void, lhs: BingoSquare, rhs: BingoSquare) bool {
            return lhs.winning_turn < rhs.winning_turn;
        }
    }.cmp;

    const first_square = squares.items[std.sort.argMin(BingoSquare, squares.items, {}, cmp) orelse unreachable];
    const last_square = squares.items[std.sort.argMax(BingoSquare, squares.items, {}, cmp) orelse unreachable];

    std.debug.print("Score of first winning square is {d}\n", .{first_square.calculateScore(draw_list)});
    std.debug.print("Score of last winning square is {d}\n", .{last_square.calculateScore(draw_list)});
}
