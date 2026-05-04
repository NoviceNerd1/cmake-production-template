#!/usr/bin/env bash
# scripts/run-tests.sh — Build (dev preset) and run all tests
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

cmake --preset dev
cmake --build --preset dev
ctest --preset dev --output-on-failure

echo "All tests passed."
