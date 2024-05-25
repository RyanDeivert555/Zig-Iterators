const std = @import("std");
const Filter = @import("filter.zig").Filter;
const Fold = @import("fold.zig").Fold;
const Take = @import("take.zig").Take;

pub fn Map(comptime Context: type, comptime T: type, comptime U: type, comptime f: fn (T) U) type {
    return struct {
        context: Context,

        const Self = @This();

        pub fn init(context: Context) Self {
            return Self{
                .context = context,
            };
        }

        pub fn next(self: *Self) ?U {
            const n = self.context.next();

            if (n) |val| {
                return f(val);
            } else {
                return null;
            }
        }

        pub fn filter(self: Self, comptime func: fn (U) bool) Filter(Self, U, func) {
            return Filter(Self, U, func).init(self);
        }

        pub fn map(self: Self, comptime V: type, func: fn (U) V) Map(Self, U, V, f) {
            return Map(Self, U, V, func).init(self);
        }

        pub fn fold(self: Self, comptime V: type, start: V, comptime func: fn (U, U) V) V {
            var result = Fold(Self, U, V, func).init(self, start);

            return result.consume();
        }

        pub fn collect(self: Self, allocator: std.mem.Allocator) !std.ArrayList(U) {
            var instance = self;
            var result = std.ArrayList(U).init(allocator);

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

        pub fn any(self: Self, predicate: fn (U) bool) bool {
            var instance = self;

            while (instance.next()) |val| {
                if (predicate(val)) {
                    return true;
                }
            }

            return false;
        }

        pub fn take(self: Self, n: usize) Take(Self, U) {
            return Take(Self, U).init(self, n);
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
