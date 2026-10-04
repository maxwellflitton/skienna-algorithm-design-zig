//! Linked list from chapter 3 of The Algorithm Design Manual.
//!
//! A doubly linked list: every node holds a value plus a pointer to the node
//! after it and the node before it. Nodes do not own their neighbours; whoever
//! allocates a node is responsible for freeing it.
const std = @import("std");

/// A doubly linked list node that holds an `i32`.
///
/// Non-generic version of `Node`, kept as a stepping stone.
const IntNode = struct {
    /// The integer stored in this node.
    value: i32,
    /// The node after this one, or `null` if this is the last node.
    next_ptr: ?*IntNode,
    /// The node before this one, or `null` if this is the first node.
    previous_ptr: ?*IntNode,

    /// Returns the node after this one, or `null` if this is the last node.
    ///
    /// Runs in O(1).
    pub fn next(self: *IntNode) ?*IntNode {
        return self.next_ptr;
    }
};

/// A doubly linked list of `i32` values.
///
/// The list always contains at least one node, its `head`. Every node is
/// allocated with `allocator`, so the list owns its nodes.
pub const IntLinkedList = struct {
    /// The first node in the list. Its `previous_ptr` is always `null`.
    head: *IntNode,
    /// The allocator used to create every node in the list.
    allocator: std.mem.Allocator,

    /// Creates a list with a single node holding `val`.
    ///
    /// `allocator` is stored in the list and used for every node it creates,
    /// including the head.
    ///
    /// Returns `error.OutOfMemory` if the head node cannot be allocated.
    pub fn new(
        allocator: std.mem.Allocator,
        val: i32,
    ) !IntLinkedList {
        // Get the pointer to the newly allocated slot
        const head = try allocator.create(IntNode);

        // set the value of the data relating to the pointer
        head.* = .{
            .value = val,
            .next_ptr = null,
            .previous_ptr = null,
        };

        return .{
            .head = head,
            .allocator = allocator,
        };
    }

    /// Returns the first node, starting from `head`, whose value equals
    /// `search_val`, or `null` if no node matches.
    ///
    /// Runs in O(n).
    pub fn search(
        self: *IntLinkedList,
        search_val: i32,
    ) ?*IntNode {
        var current: ?*IntNode = self.head;

        while (current) |node| {
            if (node.value == search_val) {
                return node;
            }

            current = node.next_ptr;
        }

        return null;
    }

    /// Inserts a new node holding `insert_val` directly after `node`.
    ///
    /// `node` must be a node in this list. The new node is linked in both
    /// directions, so the node that used to follow `node` now follows the new
    /// node.
    ///
    /// Returns `error.OutOfMemory` if the new node cannot be allocated.
    ///
    /// Runs in O(1).
    pub fn insert(
        self: *IntLinkedList,
        node: *IntNode,
        insert_val: i32,
    ) !void {
        const insert_node = try self.allocator.create(IntNode);

        insert_node.* = .{
            .value = insert_val,
            .next_ptr = node.next_ptr,
            .previous_ptr = node,
        };

        if (node.next_ptr) |next_node| {
            next_node.previous_ptr = insert_node;
        }

        node.next_ptr = insert_node;
    }

    /// Removes `node` from the list and frees it.
    ///
    /// `node` must be a node in this list. Its neighbours are linked to each
    /// other so the list stays connected in both directions.
    ///
    /// TODO: not implemented yet. Decide what happens when `node` is the
    /// head, since `head` can never be `null`.
    ///
    /// Runs in O(1).
    pub fn delete(
        self: *IntLinkedList,
        node: *IntNode,
    ) !void {
        // exit early if left pointer is None
        const left_ptr: *IntNode = if (node.previous_ptr) |left_node| {
            left_node;
        } else {
            self.allocator.destroy(node);
            return;
        };
        const right_ptr = node.next_ptr;

        // stitch it up
        left_ptr.next_ptr = right_ptr;

        // reconnect the right node if it's present
        if (right_ptr) |right_node| {
            right_node.previous_ptr = left_ptr;
        }

        // dealloc the node
        self.allocator.destroy(node);
    }

    pub fn delete_by_key(self: *IntLinkedList, key: i32) !void {
        const node = self.search(key);
        if (node) |node_ptr| {
            self.delete(node_ptr);
        }
    }
};

/// Returns a doubly linked list node type that holds a value of type `T`.
///
/// `T` can be any type. The node stores the value directly, so for slices
/// such as `[]const u8` it stores the slice, not a copy of the data it points
/// to; that data must outlive the node.
///
/// Example:
///
/// ```zig
/// const IntNode = Node(i32);
/// var node: IntNode = .{ .value = 1, .next_ptr = null, .previous_ptr = null };
/// ```
fn Node(comptime T: type) type {
    return struct {
        /// The value stored in this node.
        value: T,
        /// The node after this one, or `null` if this is the last node.
        next_ptr: ?*@This(),
        /// The node before this one, or `null` if this is the first node.
        previous_ptr: ?*@This(),

        /// Returns the node after this one, or `null` if this is the last node.
        ///
        /// Runs in O(1).
        pub fn next(self: *@This()) ?*@This() {
            return self.next_ptr;
        }

        /// Returns the node before this one, or `null` if this is the first node.
        ///
        /// Runs in O(1).
        pub fn previous(self: *@This()) ?*@This() {
            return self.previous_ptr;
        }
    };
}

/// A linked list node that holds a string slice.
///
/// The node does not own the string's bytes; they must outlive the node.
const StringNode = Node([]const u8);

// The list has no `deinit` yet, so these tests allocate from an arena and
// free everything at once. Once `deinit` exists, switch to
// `std.testing.allocator` so leaks fail the test.

test "new creates a single head node" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const list = try IntLinkedList.new(arena.allocator(), 1);

    try std.testing.expectEqual(1, list.head.value);
    try std.testing.expectEqual(null, list.head.next_ptr);
    try std.testing.expectEqual(null, list.head.previous_ptr);
}

test "insert links the new node in both directions" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    var list = try IntLinkedList.new(arena.allocator(), 1);
    try list.insert(list.head, 3);
    // Insert between 1 and 3, so the list is 1 -> 2 -> 3.
    try list.insert(list.head, 2);

    const one = list.head;
    const two = one.next_ptr.?;
    const three = two.next_ptr.?;

    try std.testing.expectEqual(2, two.value);
    try std.testing.expectEqual(3, three.value);

    try std.testing.expectEqual(null, one.previous_ptr);
    try std.testing.expectEqual(one, two.previous_ptr.?);
    try std.testing.expectEqual(two, three.previous_ptr.?);
    try std.testing.expectEqual(null, three.next_ptr);
}

test "search finds a node and its neighbours" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    var list = try IntLinkedList.new(arena.allocator(), 1);
    try list.insert(list.head, 3);
    try list.insert(list.head, 2);

    const found = list.search(2).?;
    try std.testing.expectEqual(2, found.value);
    try std.testing.expectEqual(1, found.previous_ptr.?.value);
    try std.testing.expectEqual(3, found.next_ptr.?.value);

    const head = list.search(1).?;
    try std.testing.expectEqual(list.head, head);
    try std.testing.expectEqual(null, head.previous_ptr);

    const tail = list.search(3).?;
    try std.testing.expectEqual(null, tail.next_ptr);

    try std.testing.expectEqual(null, list.search(99));
}
