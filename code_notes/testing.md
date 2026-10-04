# Testing in Zig

Zig has no setup/teardown hooks, fixtures, or test attributes. A `test "name" { ... }`
block is the equivalent of Rust's `#[test]`, and everything else is plain language features.

## Rust → Zig

| Rust | Zig |
|---|---|
| `#[test] fn foo()` | `test "foo" { ... }` |
| `#[cfg(test)] mod tests` | Not needed. `test` blocks are only compiled when testing, so they usually live in the same file next to the code. |
| `assert!`, `assert_eq!` | `try std.testing.expect(x)`, `try std.testing.expectEqual(expected, actual)` |
| Returning `Result` from a test | Every test can fail with an error, which is why each check starts with `try`. |
| `#[ignore]` | `return error.SkipZigTest;` |
| `cargo test name` | `zig test file.zig --test-filter "name"` |
| `#[should_panic]` | No direct equivalent. Return an error and check it with `expectError`. |

## Setup and teardown: a normal function plus `defer`

```zig
const std = @import("std");
const testing = std.testing;

fn setup(allocator: std.mem.Allocator) !std.ArrayList(u32) {
    var list: std.ArrayList(u32) = .empty;
    try list.appendSlice(allocator, &.{ 1, 2, 3 });
    return list;
}

test "setup + teardown" {
    const allocator = testing.allocator;
    var list = try setup(allocator);
    defer list.deinit(allocator); // teardown runs whether the test passes or fails

    try testing.expectEqualSlices(u32, &.{ 1, 2, 3 }, list.items);
}
```

- `defer` is like Rust's `Drop`, except you write it yourself, right after the thing it cleans up.
- `errdefer` runs only if the function returns an error. It's useful for undoing a half-finished setup.

## `std.testing.allocator` catches memory leaks

Pass `std.testing.allocator` into your code in tests. Any allocation that isn't freed makes
the run fail, with a stack trace pointing at where the memory was allocated.

Note: the leaking test itself still prints `OK`, but the run ends with
`1 tests leaked memory` and a non-zero exit code.

## Assertions

- `expect(bool)`
- `expectEqual(expected, actual)`
- `expectEqualSlices(T, expected, actual)` for arrays and slices
- `expectEqualStrings(a, b)` shows a readable diff when it fails
- `expectError(error.Foo, someCall())` checks that a call fails with a specific error,
  e.g. popping from an empty list

```zig
fn parse(s: []const u8) !u32 {
    return std.fmt.parseInt(u32, s, 10);
}

test "errors" {
    try testing.expectError(error.InvalidCharacter, parse("abc"));
}
```

## Running tests

- `zig build test --summary all` runs every test and prints the count. Use it to check that
  a new file's tests are being picked up.
- `zig test src/chapter_3/linked_list.zig` runs a single file.
- `zig test src/chapter_3/linked_list.zig --test-filter "push"` runs only tests whose name
  contains `push`. `zig build test` doesn't support filtering out of the box.

## Making sure tests are discovered

`zig build test` only runs `test` blocks in files that the test root actually references.
Each module entry file (`root.zig`, `chapter_3.zig`) has this so imported files' tests run:

```zig
test {
    @import("std").testing.refAllDecls(@This());
}
```

A new file must also be imported in its chapter file, e.g.
`pub const stack = @import("chapter_3/stack.zig");`, or its tests won't run.

## Other

- `@import("builtin").is_test` is `true` only in test builds, for test-only behaviour in
  non-test code.
