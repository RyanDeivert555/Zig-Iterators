const std = @import("std");
const Map = @import("map.zig").Map;
const Filter = @import("filter.zig").Filter;
const Fold = @import("fold.zig").Fold;
const Take = @import("take.zig").Take;

pub fn Range(comptime T: type) type {
    return struct {
        start: T,
        end: T,
        step: T,

        const Self = @This();

        pub fn init(start: T, end: T, step: T) Self {
            return Self{
                .start = start,
                .end = end,
                .step = step,
            };
        }

        pub fn next(self: *Self) ?T {
            // TODO: fix for backwards iters
            if (self.step < 0) {
                if (self.start > self.end) {
                    const value = self.start;
                    self.start += self.step;

                    return value;
                } else {
                    return null;
                }
            } else {
                if (self.start < self.end) {
                    const value = self.start;
                    self.start += self.step;

                    return value;
                } else {
                    return null;
                }
            }
        }

        pub fn reverse(self: Self) Range(T) {
            return Range(T).init(self.end - 1, self.start - 1, -self.step);
        }

        pub fn map(self: Self, comptime U: type, comptime f: fn (T) U) Map(Self, T, U, f) {
            return Map(Self, T, U, f).init(self);
        }

        pub fn filter(self: Self, comptime f: fn (T) bool) Filter(Self, T, f) {
            return Filter(Self, T, f).init(self);
        }

        pub fn fold(self: Self, start: T, comptime f: fn (T, T) T) T {
            var result = Fold(Self, T, f).init(self, start);

            return result.consume();
        }

        pub fn sum(self: Self) T {
            var instance = self;
            var n: T = 0;

            while (instance.next()) |val| {
                n += val;
            }

            return n;
        }

        pub fn collect(self: Self, allocator: std.mem.Allocator) !std.ArrayList(T) {
            var instance = self;
            // TODO: preallocate memory?
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
