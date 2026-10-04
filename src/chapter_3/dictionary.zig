//! Dictionary abstract data type from chapter 3 of The Algorithm Design Manual.
//!
//! A dictionary is anything that supports `search`, `insert` and `delete`.
//! Zig has no traits or interfaces, so `IntDictionary` uses the same pattern
//! as `std.mem.Allocator`: a type-erased pointer to the backing data structure
//! plus a table of function pointers (a "vtable") that know how to use it.
const std = @import("std");
const IntLinkedList = @import("linked_list.zig").IntLinkedList;

/// A dictionary of `i32` values backed by any data structure.
///
/// `IntDictionary` does not own the data structure behind it. The backing
/// structure must outlive the dictionary, and freeing it is the caller's job.
pub const IntDictionary = struct {
    /// Type-erased pointer to the backing data structure.
    ptr: *anyopaque,
    /// The backing data structure's implementations of each operation.
    vtable: *const VTable,

    /// The functions a backing data structure must provide. Each one receives
    /// `ptr` and casts it back to the concrete type. This is essentially the
    /// same as `dyn trait` in rust.
    pub const VTable = struct {
        search: *const fn (ptr: *anyopaque, value: i32) bool,
        insert: *const fn (ptr: *anyopaque, value: i32) std.mem.Allocator.Error!void,
        delete: *const fn (ptr: *anyopaque, value: i32) bool,
    };

    /// Returns `true` if `value` is in the dictionary.
    pub fn search(self: IntDictionary, value: i32) bool {
        return self.vtable.search(self.ptr, value);
    }

    /// Adds `value` to the dictionary.
    ///
    /// Returns `error.OutOfMemory` if the backing structure cannot allocate.
    pub fn insert(self: IntDictionary, value: i32) std.mem.Allocator.Error!void {
        return self.vtable.insert(self.ptr, value);
    }

    /// Removes one occurrence of `value` from the dictionary.
    ///
    /// Returns `true` if `value` was found and removed, `false` otherwise.
    pub fn delete(self: IntDictionary, value: i32) bool {
        return self.vtable.delete(self.ptr, value);
    }
};

/// Returns an `IntDictionary` backed by `list`.
///
/// `list` must outlive the returned dictionary.
pub fn fromIntLinkedList(list: *IntLinkedList) IntDictionary {
    return .{
        .ptr = list,
        .vtable = &int_linked_list_vtable,
    };
}

const int_linked_list_vtable: IntDictionary.VTable = .{
    .search = intLinkedListSearch,
    .insert = intLinkedListInsert,
    .delete = intLinkedListDelete,
};

fn intLinkedListSearch(ptr: *anyopaque, value: i32) bool {
    const list: *IntLinkedList = @ptrCast(@alignCast(ptr));
    return list.search(value) != null;
}

fn intLinkedListInsert(ptr: *anyopaque, value: i32) std.mem.Allocator.Error!void {
    const list: *IntLinkedList = @ptrCast(@alignCast(ptr));
    // Order doesn't matter in a dictionary, and inserting after the head is O(1).
    try list.insert(list.head, value);
}

fn intLinkedListDelete(ptr: *anyopaque, value: i32) bool {
    const list: *IntLinkedList = @ptrCast(@alignCast(ptr));
    const node = list.search(value) orelse return false;
    list.delete(node);
    return true;
}

// The list has no `deinit` yet, so these tests allocate from an arena. See
// the note in linked_list.zig.

test "insert and search through the dictionary" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    var list = try IntLinkedList.new(arena.allocator(), 1);
    const dict = fromIntLinkedList(&list);

    try dict.insert(2);
    try dict.insert(3);

    try std.testing.expect(dict.search(1));
    try std.testing.expect(dict.search(2));
    try std.testing.expect(dict.search(3));
    try std.testing.expect(!dict.search(99));
}

test "delete through the dictionary" {
    // Remove this line once `IntLinkedList.delete` is implemented.
    if (true) return error.SkipZigTest;

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    var list = try IntLinkedList.new(arena.allocator(), 1);
    const dict = fromIntLinkedList(&list);

    try dict.insert(2);
    try dict.insert(3);

    try std.testing.expect(dict.delete(2));
    try std.testing.expect(!dict.search(2));
    try std.testing.expect(dict.search(1));
    try std.testing.expect(dict.search(3));

    try std.testing.expect(!dict.delete(99));
}
