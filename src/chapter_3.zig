//! Chapter 3: Data Structures.
pub const linked_list = @import("chapter_3/linked_list.zig");
pub const dictionary = @import("chapter_3/dictionary.zig");
pub const tree = @import("chapter_3/tree.zig");
pub const vecdequeue = @import("chapter_3/vecdequeue.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
