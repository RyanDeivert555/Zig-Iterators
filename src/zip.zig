pub fn Zip(comptime Context1: type, comptime Context2: type, comptime T1: type, comptime T2: type) type {
    return struct {
        c1: Context1,
        c2: Context2,

        const Self = @This();

        pub fn init(context1: Context1, context2: Context2) Self {
            return Self{
                .c1 = context1,
                .c2 = context2,
            };
        }

        pub fn next(self: *Self) struct { ?T1, ?T2 } {
            const r1 = self.c1.next();
            const r2 = self.c2.next();

            return .{ r1, r2 };
        }
    };
}
