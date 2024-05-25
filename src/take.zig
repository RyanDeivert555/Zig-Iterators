const std = @import("std");
const Map = @import("map.zig").Map;
const Filter = @import("filter.zig").Filter;
const Fold = @import("fold.zig").Fold;

pub fn Take(comptime Context: type, comptime T: type) type {
    return struct {
        context: Context,
        count: usize,

        const Self = @This();

        pub fn init(context: Context, n: usize) Self {
            return Self{
                .context = context,
                .count = n,
            };
        }

        pub fn next(self: *Self) ?T {
            self.count -= 1;
            if (self.count == 0) {
                return null;
            }
            const val = self.context.next();

            return val;
        }

        pub fn map(self: Self, comptime U: type, comptime func: fn (T) U) Map(Self, T, U, func) {
            return Map(Self, T, U, func).init(self);
        }

        pub fn fold(self: Self, start: T, comptime func: fn (T, T) T) T {
            var result = Fold(Self, T, func).init(self, start);

            return result.consume();
        }

        pub fn collect(self: Self, allocator: std.mem.Allocator) !std.ArrayList(T) {
            var instance = self;
            var result = std.ArrayList(T).init(allocator);

            while (instance.next()) |val| {
                try result.append(val);
            }

            return result;
        }

        pub fn all(self: Self, predicate: fn (T) bool) bool {
            var instance = self;

            while (instance.next()) |val| {
                if (!predicate(val)) {
                    return false;
                }
            }

            return true;
        }

        pub fn any(self: Self, predicate: fn (T) bool) bool {
            var instance = self;

            while (instance.next()) |val| {
                if (predicate(val)) {
                    return true;
                }
            }

            return false;
        }

        pub fn take(self: Self, n: usize) Take(Self, T) {
            return Take(Self, T).init(self, n);
        }

        pub fn count(self: Self) usize {
            var instance = self;
            var n = @as(usize, 0);

            while (instance.next()) |_| {
                n += 1;
            }

            return n;
        }
    };
}
