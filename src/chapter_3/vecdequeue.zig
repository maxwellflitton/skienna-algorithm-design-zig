//! Double-ended queue backed by a vector, from chapter 3 of The Algorithm
//! Design Manual.
const std = @import("std");

/// Returns a double-ended queue type whose buffer holds values of type `T`.
pub fn VecDequeue(comptime T: type) type {
    return struct {
        const Self = @This();
        header: usize,
        tail: usize,
        buffer: std.ArrayList(?T),
        allocator: std.mem.Allocator,
        total: usize,

        /// Creates an empty deque.
        ///
        /// `capacity` is an optional (`?usize`). Pass `null` for no
        /// pre-allocation, or a number to reserve room for that many items up
        /// front so early pushes do not reallocate.
        pub fn init(allocator: std.mem.Allocator, capacity: ?usize) !Self {
            // `if (optional) |value|` unwraps the optional into `value` only
            // when it is not null. `.empty` is the no-allocation ArrayList.
            const buffer = if (capacity) |n|
                try std.ArrayList(?T).initCapacity(allocator, n)
            else
                std.ArrayList(?T).empty;

            return .{ .header = 0, .buffer = buffer, .allocator = allocator, .tail = 0, .total = 0 };
        }

        /// Frees the backing buffer.
        pub fn deinit(self: *Self) void {
            self.buffer.deinit(self.allocator);
        }

        pub fn push_back(self: *Self, element: T) !void {
            // expand if we're at capacity
            // `capacity` is a field, not a method, so no `()`.
            if (self.buffer.capacity <= self.total) {
                // copy over the old buffer
                var new_buffer = try std.ArrayList(?T).initCapacity(self.allocator, self.buffer.capacity * 2);
                // Zig's for loop: `for (slice) |item|`. `buffer.items` is the
                // slice of live elements; the list itself is not iterable.
                for (self.buffer.items) |i| {
                    // No `push` on ArrayList. `append` needs the allocator;
                    // `appendAssumeCapacity` skips the grow check, which is
                    // safe here because we just reserved the space.
                    new_buffer.appendAssumeCapacity(i);
                }
                self.buffer.deinit(self.allocator);
                self.buffer = new_buffer;
            }
            // append onto the end
            _ = element; // TODO: remove once `element` is used below
        }

        pub fn pop_front(self: *Self) void {
            _ = self; // TODO: remove once `self` is used below

            // pop the element aligned with the self.header

            // move the self.header up one

        }
    };
}

test "init with no capacity allocates nothing" {
    var dq = try VecDequeue(i32).init(std.testing.allocator, null);
    defer dq.deinit();
    try std.testing.expectEqual(@as(usize, 0), dq.header);
    try std.testing.expectEqual(@as(usize, 0), dq.buffer.capacity);
}

test "init with capacity reserves buffer space" {
    var dq = try VecDequeue(i32).init(std.testing.allocator, 16);
    defer dq.deinit();
    try std.testing.expect(dq.buffer.capacity >= 16);
    try std.testing.expectEqual(@as(usize, 0), dq.buffer.items.len);
}
