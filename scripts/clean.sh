#!/usr/bin/env bash
# scripts/clean.sh — Remove all build directories
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
rm -rf build build-* test-install _deps
echo "Cleaned build directories."
