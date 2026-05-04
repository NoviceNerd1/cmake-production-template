#!/usr/bin/env bash
# scripts/validate.sh — Full validation suite (mirrors CI pipeline locally)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PASS=0; FAIL=0

run_step() {
    local desc="$1"; shift
    echo ""
    echo "STEP: $desc"
    # Use || true to prevent set -e from killing the script on ((VAR++)) return 1
    if "$@"; then
        echo "RESULT: [PASS] $desc"
        PASS=$((PASS + 1))
    else
        echo "RESULT: [FAIL] $desc"
        FAIL=$((FAIL + 1))
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

# Step 3: Examples build
run_step "Examples build" bash -c "
    cmake -B build/examples --preset dev -DBUILD_EXAMPLES=ON &&
    cmake --build build/examples"

# Step 4: Benchmarks build & run
run_step "Benchmarks build & run" bash -c "
    cmake -B build/benchmarks --preset dev -DBUILD_BENCHMARKS=ON &&
    cmake --build build/benchmarks &&
    ctest --test-dir build/benchmarks -L benchmark --output-on-failure"

# Step 5: Install
run_step "Install to test-install/" bash -c "
    cmake --install build/release --prefix '$ROOT/test-install'"

# Step 6: Packaging
run_step "CPack tarball" bash -c "
    cpack --config '$ROOT/build/release/CPackConfig.cmake' \
          -B '$ROOT/build/release/packages'"

echo ""
echo "========================================"
echo "Final Results: ${PASS} passed, ${FAIL} failed"
echo "========================================"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
