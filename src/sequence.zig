const std = @import("std");
const Iterator = @import("iterator.zig").Iterator;
const Map = @import("map.zig").Map;
const Filter = @import("filter.zig").Filter;
const Fold = @import("fold.zig").Fold;
const Take = @import("take.zig").Take;
const Zip = @import("zip.zig").Zip;

pub fn Sequence(comptime T: type) type {
    return struct {
        slice: []const T,
        index: usize = 0,

        const Self = @This();

        pub fn init(slice: []const T) Self {
            return Self{
                .slice = slice,
            };
        }

        pub fn next(self: *Self) ?T {
            if (self.index >= self.slice.len) {
                return null;
            }
            const result = self.slice[self.index];
            self.index += 1;

            return result;
        }

        pub fn toIter(self: Self) Iterator(Self, T) {
            return Iterator(Self, T).init(self);
        }

        pub fn map(self: Self, comptime U: type, comptime func: fn (T) U) Map(Self, T, U, func) {
            return Map(Self, T, U, func).init(self);
        }

        pub fn filter(self: Self, comptime func: fn (T) bool) Filter(Self, T, func) {
            return Filter(Self, T, func).init(self);
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
            return self.slice.len;
        }

        pub fn zip(self: Self, comptime Other: type, comptime U: type, other: Other) Zip(Self, Other, T, U) {
            return Zip(Self, Other, T, U).init(self, other);
        }
    };
}
