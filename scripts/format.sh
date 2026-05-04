#!/usr/bin/env bash
# scripts/format.sh — Format all C++ source files with clang-format
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v clang-format &>/dev/null; then
    echo "ERROR: clang-format not found — install it and retry."
    exit 1
fi

find src tests examples benchmarks \
    \( -name '*.cpp' -o -name '*.h' -o -name '*.hpp' \) \
    | xargs clang-format -i

echo "Source files formatted."
