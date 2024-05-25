pub fn Fold(comptime Context: type, comptime T: type, comptime U: type, comptime f: fn (T, T) U) type {
    return struct {
        context: Context,
        acc: U,

        const Self = @This();

        pub fn init(context: Context, start: U) Self {
            return Self{
                .context = context,
                .acc = start,
            };
        }

        pub fn consume(self: *Self) U {
            while (self.context.next()) |val| {
                self.acc = f(self.acc, val);
            }

            return self.acc;
        }
    };
}
