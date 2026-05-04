#!/usr/bin/env bash
# scripts/validate.sh — Full validation suite (mirrors CI pipeline locally)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PASS=0; FAIL=0

run_step() {
    local desc="$1"; shift
    echo ""
    echo ">>> $desc"
    if "$@"; then
        echo "    [PASS] $desc"
        ((PASS++))
    else
        echo "    [FAIL] $desc"
        ((FAIL++))
    fi
}

# -- Clean slate
"$ROOT/scripts/clean.sh"

# Step 1: Development build + tests
run_step "Dev build & tests" bash -c "
    cmake --preset dev &&
    cmake --build --preset dev &&
    ctest --preset dev --output-on-failure"

# Step 2: Release build
run_step "Release build" bash -c "
    cmake --preset release &&
    cmake --build --preset release"

# Step 3: Examples
run_step "Examples build" bash -c "
    cmake -B build/examples --preset dev -DBUILD_EXAMPLES=ON &&
    cmake --build build/examples"

# Step 4: Install
run_step "Install to test-install/" bash -c "
    cmake --install build/release --prefix '$ROOT/test-install'"

# Step 5: Packaging
run_step "CPack tarball" bash -c "
    cpack --config '$ROOT/build/release/CPackConfig.cmake' \
          -B '$ROOT/build/release/packages'"

echo ""
echo "========================================"
echo "Results: ${PASS} passed, ${FAIL} failed"
echo "========================================"
[ "$FAIL" -eq 0 ]
