const std = @import("std");
const Iterator = @import("iterator.zig").Iterator;
const Map = @import("map.zig").Map;
const Fold = @import("fold.zig").Fold;
const Take = @import("take.zig").Take;
const Zip = @import("zip.zig").Zip;

pub fn Filter(comptime Context: type, comptime T: type, comptime f: fn (T) bool) type {
    return struct {
        context: Context,

        const Self = @This();

        pub fn init(context: Context) Self {
            return Self{
                .context = context,
            };
        }

        pub fn next(self: *Self) ?T {
            while (self.context.next()) |val| {
                if (f(val)) {
                    return val;
                }
            }

            return null;
        }

        pub fn toIter(self: Self) Iterator(Self, T) {
            return Iterator(Self, T).init(self);
        }

        pub fn filter(self: Self, comptime predicate: fn (T) bool) Filter(Self, T, predicate) {
            return Filter(Self, T, predicate).init(self);
        }

        pub fn map(self: Self, comptime U: type, comptime func: fn (T) U) Map(Self, T, U, func) {
            return Map(Self, T, U, func).init(self);
        }

        pub fn fold(self: Self, comptime U: type, start: U, comptime func: fn (T, T) U) U {
            var result = Fold(Self, T, U, func).init(self, start);

            return result.consume();
        }

        pub fn collect(self: Self, allocator: std.mem.Allocator) !std.ArrayList(T) {
            return self.toIter().collect(allocator);
        }

        pub fn all(self: Self, predicate: fn (T) bool) bool {
            return self.toIter().all(predicate);
        }

        pub fn any(self: Self, predicate: fn (T) bool) bool {
            return self.toIter().any(predicate);
        }

        pub fn take(self: Self, n: usize) Take(Self, T) {
            return Take(Self, T).init(self, n);
        }

        pub fn count(self: Self) usize {
            return self.toIter().count();
        }

        pub fn zip(self: Self, comptime Other: type, comptime U: type, other: Other) Zip(Self, Other, T, U) {
            return Zip(Self, Other, T, U).init(self, other);
        }
    };
}
