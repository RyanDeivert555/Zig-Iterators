pub fn Fold(comptime Context: type, comptime T: type, comptime f: fn (T, T) T) type {
    return struct {
        context: Context,
        acc: T,

        const Self = @This();

        pub fn init(context: Context, start: T) Self {
            return Self{
                .context = context,
                .acc = start,
            };
        }

        pub fn consume(self: *Self) T {
            while (self.context.next()) |val| {
                self.acc = f(self.acc, val);
            }

            return self.acc;
        }
    };
}
