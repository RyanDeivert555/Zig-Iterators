const std = @import("std");
const Iterator = @import("iterator.zig").Iterator;
const Filter = @import("filter.zig").Filter;
const Map = @import("map.zig").Map;
const Fold = @import("fold.zig").Fold;
const Take = @import("take.zig").Take;
const Zip = @import("zip.zig").Zip;

pub fn FilterMap(comptime Context: type, comptime T: type, comptime U: type, comptime f: fn (?T) ?U) type {
    return struct {
        context: Context,

        const Self = @This();

        pub fn init(context: Context) Self {
            return Self{
                .context = context,
            };
        }

        pub fn next(self: *Self) ?U {
            while (self.context.next()) |n| {
                if (f(n)) |v| {
                    return v;
                }
            }

            return null;
        }

        pub fn toIter(self: Self) Iterator(Self, ?U) {
            return Iterator(Self, ?U).init(self);
        }

        pub fn filter(self: Self, comptime func: fn (?U) bool) Filter(Self, ?U, func) {
            return Filter(Self, ?U, func).init(self);
        }

        pub fn map(self: Self, comptime V: type, func: fn (?U) V) Map(Self, ?U, V, f) {
            return Map(Self, ?U, V, func).init(self);
        }

        pub fn fold(self: Self, comptime V: type, start: V, comptime func: fn (?U, ?U) V) V {
            var result = Fold(Self, ?U, V, func).init(self, start);

            return result.consume();
        }

        pub fn collect(self: Self, allocator: std.mem.Allocator) !std.ArrayList(U) {
            return self.toIter().collect(allocator);
        }

        pub fn all(self: Self, predicate: fn (?U) bool) bool {
            return self.toIter().all(predicate);
        }

        pub fn any(self: Self, predicate: fn (?U) bool) bool {
            return self.toIter().any(predicate);
        }

        pub fn take(self: Self, n: usize) Take(Self, ?U) {
            return Take(Self, ?U).init(self, n);
        }

        pub fn count(self: Self) usize {
            return self.toIter().count();
        }

        pub fn zip(self: Self, comptime Other: type, comptime V: type, other: Other) Zip(Self, Other, ?U, V) {
            return Zip(Self, Other, ?U, V).init(self, other);
        }
    };
}
