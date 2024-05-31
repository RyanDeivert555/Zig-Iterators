const std = @import("std");
const Map = @import("map.zig").Map;
const Filter = @import("filter.zig").Filter;
const Fold = @import("fold.zig").Fold;
const Take = @import("take.zig").Take;
const Zip = @import("zip.zig").Zip;

pub fn Iterator(comptime Context: type, comptime T: type) type {
    return struct {
        context: Context,

        const Self = @This();

        pub fn init(context: Context) Self {
            return Self{
                .context = context,
            };
        }

        pub fn next(self: *Self) ?T {
            return self.context.next();
        }

        // pub fn map(self: Self, comptime U: type, comptime f: fn (T) U) Map(Self, T, U, f) {
        //     return Map(Self, T, U, f).init(self);
        // }

        // pub fn filter(self: Self, comptime f: fn (T) bool) Filter(Self, T, f) {
        //     return Filter(Self, T, f).init(self);
        // }

        // pub fn fold(self: Self, comptime U: type, start: U, comptime f: fn (T, T) U) U {
        //     var instance = Fold(Self, T, U, f).init(self, start);

        //     return instance.consume();
        // }

        pub fn collect(self: Self, allocator: std.mem.Allocator) !std.ArrayList(T) {
            var instance = self;
            var result = std.ArrayList(T).init(allocator);

            while (instance.next()) |v| {
                try result.append(v);
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

        // pub fn take(self: Self, n: usize) Take(Self, T) {
        //     return Take(Self, T).init(self, n);
        // }

        pub fn count(self: Self) usize {
            var instance = self;
            var n = @as(usize, 0);

            while (instance.next()) |_| {
                n += 1;
            }

            return n;
        }

        // pub fn zip(self: Self, comptime Other: type, comptime U: type, other: Other) Zip(Self, Other, T, U) {
        //     return Zip(Self, Other, T, U).init(self, other);
        // }
    };
}
