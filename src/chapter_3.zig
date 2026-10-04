//! Chapter 3: Data Structures.
pub const linked_list = @import("chapter_3/linked_list.zig");
pub const dictionary = @import("chapter_3/dictionary.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
