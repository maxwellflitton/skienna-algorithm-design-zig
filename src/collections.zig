//! Reusable containers shared across chapters.
pub const vec = @import("collections/vec.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
