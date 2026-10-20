// const IntNode = @import("linked_list.zig").IntNode;
const std = @import("std");

pub const IntNode = struct { value: i32, left_ptr: ?*IntNode, right_ptr: ?*IntNode };

pub const IntTree = struct {
    /// the pointer to the head of the tree
    header_ptr: ?*IntNode,
    /// The current pointer in a search
    current_ptr: ?*IntNode,
    /// The allocator used to create every node in the list.
    allocator: std.mem.Allocator,

    pub fn new(
        allocator: std.mem.Allocator,
        val: i32,
    ) !IntTree {
        const header_ptr = try allocator.create(IntNode);
        header_ptr.* = .{
            .value = val,
            .left_ptr = null,
            .right_ptr = null,
        };
        return .{ .header_ptr = header_ptr, .allocator = allocator, .current_ptr = header_ptr };
    }

    pub fn insert(self: *IntTree, value: i32) !void {
        self.header_ptr = try recursiveInsert(self, self.header_ptr, value);
    }

    /// The recursive approach takes the following form:
    ///
    /// ```
    /// FUNCTION insert(node, value):
    ///     IF node IS NULL:
    ///         RETURN new Node(value)
    ///
    ///     IF value < node.value:
    ///         node.left = insert(node.left, value)
    ///
    ///     ELSE IF value > node.value:
    ///         node.right = insert(node.right, value)
    ///     RETURN node
    /// ```
    ///
    fn recursiveInsert(self: *IntTree, current: ?*IntNode, value: i32) !*IntNode {
        if (current) |node| {
            // we skip the = to ignore duplicates
            if (value < node.value) {
                node.left_ptr = try recursiveInsert(self, node.left_ptr, value);
            } else if (value > node.value) {
                node.right_ptr = try recursiveInsert(self, node.right_ptr, value);
            }
            return node;
        } else {
            // insert the node
            const insert_node = try self.allocator.create(IntNode);
            insert_node.* = .{ .value = value, .left_ptr = null, .right_ptr = null };
            return insert_node;
        }
    }

    /// The iterative insert takes the following form:
    ///
    /// ```
    /// WHILE TRUE:
    ///     IF value < current.value:
    ///         IF current.left IS NULL:
    ///              current.left = newNode
    ///              BREAK
    ///         current = current.left
    ///
    ///     ELSE IF value > current.value:
    ///         IF current.right IS NULL:
    ///             current.right = newNode
    ///                BREAK
    ///         current = current.right
    ///
    ///     ELSE:
    ///         BREAK // duplicate value
    ///  RETURN root
    fn iterativeInsert(self: *IntTree, value: i32) void {
        var flag = true;
        while (flag) {
            flag = false;
        }
    }

    // pub fn binarySearch(self: *IntTree, search_term: i32) void {
    //     if (self.current_ptr.?.left_ptr < search_term) {} else {}
    // }
};

test "recurrsive insert" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    var tree = try IntTree.new(arena.allocator(), 5);
    try tree.insert(6);
    try tree.insert(4);
}
