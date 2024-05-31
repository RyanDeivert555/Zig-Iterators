const std = @import("std");
const Iterator = @import("iterator.zig").Iterator;
const Map = @import("map.zig").Map;
const Filter = @import("filter.zig").Filter;
const Fold = @import("fold.zig").Fold;
const Take = @import("take.zig").Take;

pub fn Zip(comptime Context1: type, comptime Context2: type, comptime T1: type, comptime T2: type) type {
    return struct {
        c1: Context1,
        c2: Context2,

        const Self = @This();
        const Tuple = struct { T1, T2 };

        pub fn init(context1: Context1, context2: Context2) Self {
            return Self{
                .c1 = context1,
                .c2 = context2,
            };
        }

        pub fn next(self: *Self) ?Tuple {
            const left = self.c1.next() orelse return null;
            const right = self.c2.next() orelse return null;

            return .{ left, right };
        }

        pub fn toIter(self: Self) Iterator(Self, Tuple) {
            return Iterator(Self, Tuple).init(self);
        }

        pub fn map(self: Self, comptime U: type, comptime f: fn (Tuple) U) Map(Self, Tuple, U, f) {
            return Map(Self, Tuple, U, f).init(self);
        }

        pub fn filter(self: Self, comptime f: fn (Tuple) bool) Filter(Self, Tuple, f) {
            return Filter(Self, Tuple, f).init(self);
        }

        pub fn fold(self: Self, comptime U: type, start: U, comptime f: fn (Tuple, Tuple) U) U {
            var result = Fold(Self, Tuple, U, f).init(self, start);

            return result.consume();
        }

        pub fn collect(self: Self, allocator: std.mem.Allocator) !std.ArrayList(Tuple) {
            return self.toIter().collect(allocator);
        }

        pub fn all(self: Self, predicate: fn (Tuple) bool) bool {
            return self.toIter().all(predicate);
        }

        pub fn any(self: Self, predicate: fn (Tuple) bool) bool {
            return self.toIter().any(predicate);
        }

        pub fn take(self: Self, n: usize) Take(Self, Tuple) {
            return Take(Self, Tuple).init(self, n);
        }

        pub fn count(self: Self) usize {
            return self.toIter().count();
        }

        pub fn zip(self: Self, comptime Other: type, comptime U: type, other: Other) Zip(Self, Other, Tuple, U) {
            return Zip(Self, Other, Tuple, U).init(self, other);
        }
    };
}
