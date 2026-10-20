//! A growable array, generic over its element type.
const std = @import("std");

/// Returns a vector type whose buffer holds values of type `T`.
///
/// Zig has no built-in generics. Instead, a function that takes a `comptime`
/// type and returns a `type` is the generic. `Vec(i32)` and `Vec(u8)` are two
/// distinct struct types, generated at compile time.
pub fn Vec(comptime T: type) type {
    return struct {
        /// `@This()` refers to the anonymous struct being returned, so methods
        /// can name their own type.
        const Self = @This();

        /// Heap memory owned by the vector. `buffer.len` is the capacity.
        buffer: []T,
        /// Number of slots in `buffer` that hold a real value.
        len: usize,
        /// Allocator used for `buffer`; every resize goes through it.
        allocator: std.mem.Allocator,

        /// Creates an empty vector with no backing memory yet.
        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .buffer = &[_]T{},
                .len = 0,
                .allocator = allocator,
            };
        }

        /// Frees the backing buffer.
        pub fn deinit(self: *Self) void {
            // TODO: free `self.buffer` with `self.allocator`
            _ = self;
        }

        /// Appends `value` to the end, growing the buffer if full.
        pub fn push(self: *Self, value: T) !void {
            // TODO: if len == buffer.len, grow (e.g. double capacity)
            // TODO: write value at buffer[len], then increment len
            _ = self;
            _ = value;
        }

        /// Removes and returns the last value, or `null` if empty.
        pub fn pop(self: *Self) ?T {
            // TODO
            _ = self;
            return null;
        }

        /// Returns the value at `index`, or `null` if out of bounds.
        pub fn get(self: *Self, index: usize) ?T {
            // TODO
            _ = self;
            _ = index;
            return null;
        }
    };
}

test "Vec is generic over T" {
    var ints = Vec(i32).init(std.testing.allocator);
    defer ints.deinit();
    var bytes = Vec(u8).init(std.testing.allocator);
    defer bytes.deinit();
    try std.testing.expectEqual(@as(usize, 0), ints.len);
    try std.testing.expectEqual(@as(usize, 0), bytes.len);
}
