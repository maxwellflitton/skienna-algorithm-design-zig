#!/usr/bin/env bash
# Builds and runs src/main.zig. Any arguments are passed through to the program,
# e.g. `scripts/run.sh hello world`.
set -euo pipefail

cd "$(dirname "$0")/.."
zig build run -- "$@"
