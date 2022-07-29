const std = @import("std");
const builtin = @import("builtin");

const PacketType = enum(u3) {
    Sum,
    Product,
    Minimum,
    Maximum,
    Literal,
    GreaterThan,
    LessThan,
    EqualTo,
};

const Packet = struct {
    version: u3,
    packet_type: PacketType,
    value: u64 = 0,
    version_sum: u64 = 0,
};

const Parser = struct {
    const Self = @This();

    const Window = u64;

    data: []const Window = undefined,
    index: usize = 0,
    window: Window = undefined,
    bit: std.math.Log2Int(Window) = 0,
    allocator: std.mem.Allocator,
    processed: usize = 0,
    version_sum: u64 = 0,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
        };
    }

    /// Read N bits from the window and adjust the starting bit pointer. If reading
    /// more bits than are remaining in the window, read the next window from the buffer
    /// to get the remaining bits
    fn read(self: *Self, comptime N: comptime_int) std.meta.Int(.unsigned, N) {
        const U = std.meta.Int(.unsigned, N);
        defer {
            self.bit +%= N;
            self.processed += N;
        }

        if (self.bit < @bitSizeOf(Window) - N) {
            return @truncate(U, self.window >> ((@bitSizeOf(Window) - 1) - self.bit - N + 1));
        }

        // Read in next word
        self.index += 1;
        var val = self.window << self.bit;
        self.window = self.data[self.index];
        val |= (self.window >> ((@bitSizeOf(Window) - 1) - self.bit + 1));
        val >>= @bitSizeOf(Window) - N;

        return @truncate(U, val);
    }

    pub fn parseHex(self: *Self, hex: []const u8) !Packet {
        var bytes = try self.allocator.alignedAlloc(u8, @alignOf(Window), std.mem.alignForward(hex.len / 2, @alignOf(Window)));
        defer self.allocator.free(bytes);

        std.mem.set(u8, bytes, 0);

        _ = try std.fmt.hexToBytes(bytes, hex);

        for (std.mem.bytesAsSlice(Window, bytes)) |*b| {
            b.* = std.mem.nativeToBig(Window, b.*);
        }

        return self.parseBytes(bytes);
    }

    pub fn parseBytes(self: *Self, bytes: []align(@alignOf(Window)) const u8) Packet {
        self.data = std.mem.bytesAsSlice(Window, bytes);
        self.index = 0;
        self.bit = 0;
        self.processed = 0;
        self.version_sum = 0;
        self.window = self.data[0];

        var packet = self.parse();
        packet.version_sum = self.version_sum;
        return packet;
    }

    fn parse(self: *Self) Packet {
        var packet = Packet{
            .version = self.read(3),
            .packet_type = @intToEnum(PacketType, self.read(3)),
        };

        self.version_sum += packet.version;

        packet.value = switch (packet.packet_type) {
            .Literal => self.parseLiteral(),
            else => self.parseOperator(packet.packet_type),
        };

        return packet;
    }

    fn parseLiteral(self: *Self) u64 {
        var result: u64 = 0;

        while (true) {
            const v = self.read(5);
            result = (result << 4) | (v & 0xF);
            if (v & 0x10 == 0) {
                break;
            }
        }

        return result;
    }

    fn parseOperator(self: *Self, packet_type: PacketType) u64 {
        const calcResult = struct {
            fn closure(x: u64, t: PacketType, i: usize, subpacket: Packet) u64 {
                return switch (t) {
                    .Sum => x + subpacket.value,
                    .Product => x * subpacket.value,
                    .Minimum => @minimum(x, subpacket.value),
                    .Maximum => @maximum(x, subpacket.value),
                    .GreaterThan => if (i == 0)
                        subpacket.value
                    else
                        @boolToInt(x > subpacket.value),
                    .LessThan => if (i == 0)
                        subpacket.value
                    else
                        @boolToInt(x < subpacket.value),
                    .EqualTo => if (i == 0)
                        subpacket.value
                    else
                        @boolToInt(x == subpacket.value),
                    else => unreachable,
                };
            }
        }.closure;

        var result: u64 = switch (packet_type) {
            .Product => 1,
            .Minimum => std.math.maxInt(u64),
            else => 0,
        };

        const length_type_id = self.read(1);
        if (length_type_id == 0) {
            const length = self.read(15);
            const processed = self.processed;
            var i: usize = 0;
            while (self.processed < processed + length) : (i += 1) {
                result = calcResult(result, packet_type, i, self.parse());
            }
        } else {
            const length = self.read(11);
            var i: usize = 0;
            while (i < length) : (i += 1) {
                result = calcResult(result, packet_type, i, self.parse());
            }
        }

        return result;
    }
};

fn solve(parser: *Parser, input: []const u8) !void {
    _ = try parser.parseHex(input);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    const input = @embedFile("input.txt");

    var parser = Parser.init(allocator);
    const packet = try parser.parseHex(input[0 .. input.len - 1]);

    std.debug.print("Part 1: {}\n", .{packet.version_sum});
    std.debug.print("Part 2: {}\n", .{packet.value});

    // For benchmarking
    // var i: usize = 0;
    // while (i < 10000) : (i += 1) {
    //     try solve(&parser, input[0 .. input.len - 1]);
    // }
}

test "Parser" {
    var parser = Parser.init(std.testing.allocator);

    {
        const packet = try parser.parseHex("8A004A801A8002F478");
        try std.testing.expectEqual(packet.version_sum, 16);
    }

    {
        const packet = try parser.parseHex("620080001611562C8802118E34");
        try std.testing.expectEqual(packet.version_sum, 12);
    }

    {
        const packet = try parser.parseHex("C0015000016115A2E0802F182340");
        try std.testing.expectEqual(packet.version_sum, 23);
    }

    {
        const packet = try parser.parseHex("A0016C880162017C3686B18A3D4780");
        try std.testing.expectEqual(packet.version_sum, 31);
    }

    {
        const packet = try parser.parseHex("C200B40A82");
        try std.testing.expectEqual(packet.value, 3);
    }

    {
        const packet = try parser.parseHex("04005AC33890");
        try std.testing.expectEqual(packet.value, 54);
    }

    {
        const packet = try parser.parseHex("880086C3E88112");
        try std.testing.expectEqual(packet.value, 7);
    }

    {
        const packet = try parser.parseHex("CE00C43D881120");
        try std.testing.expectEqual(packet.value, 9);
    }

    {
        const packet = try parser.parseHex("D8005AC2A8F0");
        try std.testing.expectEqual(packet.value, 1);
    }

    {
        const packet = try parser.parseHex("F600BC2D8F");
        try std.testing.expectEqual(packet.value, 0);
    }

    {
        const packet = try parser.parseHex("9C005AC2F8F0");
        try std.testing.expectEqual(packet.value, 0);
    }

    {
        const packet = try parser.parseHex("9C0141080250320F1802104A08");
        try std.testing.expectEqual(packet.value, 1);
    }
}
