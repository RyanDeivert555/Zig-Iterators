const std = @import("std");
const Range = @import("range.zig").Range;

fn isEven(x: usize) bool {
    return @mod(x, 2) == 0;
}

fn add(x: usize, y: usize) usize {
    return x + y;
}

fn addOne(x: usize) usize {
    return x + 1;
}

// TODO: zip/zip longest, filter map
// TODO: why is filter so slow?

pub fn main() !void {
    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = allocator.allocator();
    var argsIterator = try std.process.ArgIterator.initWithAllocator(gpa);
    defer argsIterator.deinit();
    _ = argsIterator.skip();

    const test_iter = l: {
        if (argsIterator.next()) |val| {
            break :l std.mem.eql(u8, val, "true");
        } else {
            break :l false;
        }
    };

    const max = 1_000_000_000;

    const sum = l: {
        if (test_iter) {
            const sum = Range(usize).init(0, max, 1).map(usize, addOne).filter(isEven).fold(usize, 0, add);

            break :l sum;
        } else {
            var sum: usize = 0;
            for (0..max) |i| {
                if (@mod(i + 1, 2) == 0) {
                    sum += i + 1;
                }
            }

            break :l sum;
        }
    };

    std.debug.print("The sum is {d}\n", .{sum});
}

test "count" {
    {
        const count = Range(i32).init(0, 10, 1).count();
        try std.testing.expect(count == 10);
    }
    {
        const count = Range(i32).init(0, 10, 2).count();
        try std.testing.expect(count == 5);
    }
    {
        const count = Range(i32).init(10, 0, -1).count();
        try std.testing.expect(count == 10);
    }
    {
        const count = Range(i32).init(0, 10, 1).reverse().count();
        try std.testing.expect(count == 10);
    }
}

test "map" {
    {
        var map = Range(i32).init(0, 10, 1).map(f32, struct {
            pub fn f(x: i32) f32 {
                return @floatFromInt(x + 1);
            }
        }.f);

        try std.testing.expectEqual(1.0, map.next());
        try std.testing.expectEqual(2.0, map.next());
        try std.testing.expectEqual(3.0, map.next());
        try std.testing.expectEqual(4.0, map.next());
        try std.testing.expectEqual(5.0, map.next());
        try std.testing.expectEqual(6.0, map.next());
        try std.testing.expectEqual(7.0, map.next());
        try std.testing.expectEqual(8.0, map.next());
        try std.testing.expectEqual(9.0, map.next());
        try std.testing.expectEqual(10.0, map.next());
        try std.testing.expectEqual(null, map.next());
    }
}
