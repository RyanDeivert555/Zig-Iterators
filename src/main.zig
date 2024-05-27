const std = @import("std");
const Range = @import("range.zig").Range;
const Sequence = @import("sequence.zig").Sequence;

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
            const sum = Range(usize).init(0, max, 1).map(usize, addOne).fold(usize, 0, add);

            break :l sum;
        } else {
            var sum: usize = 0;
            for (0..max) |i| {
                sum += i + 1;
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

test "take" {
    var take = Range(i32).init(0, std.math.maxInt(i32), 1).take(100);

    try std.testing.expectEqual(take.count(), 100);

    var i: i32 = 0;
    while (take.next()) |v| : (i += 1) {
        try std.testing.expectEqual(v, i);
    }
}

test "sequence" {
    // is Sequence even necessary?
    var seq = Sequence(i32).init(&[_]i32{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 });

    var i: i32 = 0;
    while (seq.next()) |v| : (i += 1) {
        try std.testing.expectEqual(i, v);
    }
}
