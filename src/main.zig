const std = @import("std");
const Range = @import("range.zig").Range;
const Sequence = @import("sequence.zig").Sequence;
const Zip = @import("zip.zig").Zip;

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

test "zip" {
    const seq1 = Sequence(i32).init(&[_]i32{ 0, 1, 2, 3, 4 });
    const seq2 = Sequence(u32).init(&[_]u32{ 11, 12 });

    // shouldnt be made manually
    var zip = Zip(Sequence(i32), Sequence(u32), i32, u32).init(seq1, seq2);

    {
        const result = zip.next();
        try std.testing.expect(result != null);

        const v1, const v2 = result.?;
        try std.testing.expectEqual(v1, 0);
        try std.testing.expectEqual(v2, 11);
    }
    {
        const result = zip.next();
        try std.testing.expect(result != null);

        const v1, const v2 = result.?;
        try std.testing.expectEqual(v1, 1);
        try std.testing.expectEqual(v2, 12);
    }
    {
        const result = zip.next();
        try std.testing.expect(result == null);
    }
}

test "zip with combinators" {
    const evens = Range(i32).init(0, 100, 1).filter(struct {
        fn f(x: i32) bool {
            return @mod(x, 2) == 0;
        }
    }.f);
    const odds = Range(i32).init(0, 100, 1).filter(struct {
        fn f(x: i32) bool {
            return @mod(x, 2) == 1;
        }
    }.f);

    // TypeOf feels like a hiccup
    var iter = evens.zip(@TypeOf(odds), i32, odds).map(i32, struct {
        fn f(x: struct { i32, i32 }) i32 {
            const x1, const x2 = x;

            return x1 + x2;
        }
    }.f);

    var even_check = @as(i32, 0);
    var odds_check = @as(i32, 1);

    while (iter.next()) |v| {
        try std.testing.expectEqual(v, even_check + odds_check);

        even_check += 2;
        odds_check += 2;
    }
}
