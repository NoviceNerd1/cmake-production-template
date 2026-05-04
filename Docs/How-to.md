# How-To: Build a Production CMake Template From Scratch

> Step-by-step reproduction guide — every command and file I created, in exact order.

---

## Prerequisites

Install these tools before starting:

```bash
# macOS (Homebrew)
brew install cmake ninja git

# Linux (apt)
sudo apt-get install cmake ninja-build git build-essential

# Verify versions
cmake --version   # Need 3.20+
ninja --version   # Need 1.10+
git   --version
```

**Optional but recommended:**

```bash
brew install ccache   # faster rebuilds
brew install doxygen  # API docs
```

---

## Phase 1 — Directory Structure & Git  *(Day 1)*

### Step 1.1 — Create the project root

```bash
mkdir -p ~/projects/cmake-template
cd ~/projects/cmake-template
```

### Step 1.2 — Create all directories at once

```bash
mkdir -p \
  src/core/include/core    src/core/src \
  src/network/include/network  src/network/src \
  src/app \
  include/myproject \
  tests/core  tests/network \
  benchmarks \
  tools/codegen  tools/debug \
  examples/basic_server \
  docs/api \
  scripts \
  cmake/FindModules  cmake/CPack \
  .github/workflows
```

### Step 1.3 — Initialise Git

```bash
git init
git branch -m main    # rename to main (optional)
```

### Step 1.4 — Create `.gitignore`

Create `.gitignore` with:
- `build/`, `build-*/`, `out/`
- CMake artifacts (`CMakeCache.txt`, `CMakeFiles/`, etc.)
- Generated headers (`config.h`)
- Object files and executables
- IDE files (`.vscode/`, `.idea/`)
- OS files (`.DS_Store`, `Thumbs.db`)
- `_deps/` (FetchContent downloads)

> **Key rule:** Whitelist `cmake/*.cmake` files while blacklisting generated `*.cmake`.

### Step 1.5 — Create `CMakeLists.txt` (root orchestrator)

The root file does exactly these things in order:
1. `cmake_minimum_required(VERSION 3.20)`
2. `project(MyProject VERSION 1.0.0 LANGUAGES CXX)`
3. `include(cmake/options.cmake)` — must be first
4. `include(cmake/compiler.cmake)`
5. `include(cmake/platform.cmake)`
6. `include(cmake/dependencies.cmake)`
7. `include(cmake/Utils.cmake)` — must be before `add_subdirectory()`
8. `add_subdirectory(src)`
9. Conditional: `add_subdirectory(tests)` if `BUILD_TESTING`
10. Conditional: `add_subdirectory(benchmarks)` if `BUILD_BENCHMARKS`
11. Conditional: `add_subdirectory(examples)` if `BUILD_EXAMPLES`
12. Conditional: Doxygen target if `BUILD_DOCS`
13. `include(cmake/install.cmake)`
14. `include(cmake/packaging.cmake)`
15. Print a build summary with `message(STATUS ...)`

### Step 1.6 — Create `CMakePresets.json`

Define 4 presets — all inherit from a hidden `default` preset:

| Preset | BUILD_TYPE | Tests | Sanitizers | Notes |
|--------|-----------|-------|------------|-------|
| `dev` | Debug | ON | OFF | Daily dev |
| `dev-asan` | Debug | ON | ASAN+UBSAN | Memory debugging |
| `release` | Release | OFF | OFF | Production |
| `ci` | RelWithDebInfo | ON | ASAN+UBSAN | Full CI |

> The `default` preset sets: `generator: "Ninja"`, `CMAKE_CXX_STANDARD: 20`, `CMAKE_EXPORT_COMPILE_COMMANDS: ON`.

> **Gotcha:** `verbosity` inside `testPresets[].output` is not a valid key in schema version 3. Use only `outputOnFailure`.

### Step 1.7 — First commit

```bash
git add -A
git commit -m "Day 1: directory structure, root CMakeLists, presets"
```

---

## Phase 2 — Options & Compiler Modules  *(Day 2)*

### Step 2.1 — `cmake/options.cmake`

This file defines all user-configurable `option()` and `set(... CACHE ...)` variables:

**Categories of options:**
- **Build** — `BUILD_TESTING`, `BUILD_BENCHMARKS`, `BUILD_EXAMPLES`, `BUILD_DOCS`, `BUILD_SHARED_LIBS`
- **Optimisation** — `ENABLE_LTO`, `ENABLE_UNITY_BUILD`, `ENABLE_PRECOMPILED_HEADERS`, `ENABLE_CCACHE`
- **Sanitizers** — `ENABLE_ASAN`, `ENABLE_UBSAN`, `ENABLE_TSAN`, `ENABLE_LSAN`
- **Quality** — `ENABLE_WARNINGS_AS_ERRORS`, `ENABLE_COVERAGE`, `ENABLE_CPPCHECK`, `ENABLE_CLANG_TIDY`
- **Packaging** — `PACKAGE_TGZ`, `PACKAGE_DEB`, `PACKAGE_RPM`, `PACKAGE_NSIS`
- **Tuning** — `MAX_CONNECTION_COUNT`, `STAT_CACHE_TTL`, `IO_BUFFER_SIZE` (CACHE STRING)

**End of file:** Extract git hash with `execute_process(git log -1 --format=%h)`, then call `configure_file(config.h.in → build/generated/config.h)`.

### Step 2.2 — `config.h.in`

This template is stamped by CMake into `build/generated/config.h`. Use:
- `@PROJECT_VERSION_MAJOR@` — substituted by CMake
- `#cmakedefine FEATURE 1` — becomes `#define FEATURE 1` or is omitted
- C preprocessor `#if defined(...)` for compiler/platform detection (done at compile time, not configure time)

### Step 2.3 — `cmake/compiler.cmake`

Sets `CMAKE_CXX_STANDARD 20` globally, then branches on `CMAKE_CXX_COMPILER_ID`:

**GCC/Clang/AppleClang block:**
```cmake
add_compile_options(-Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wsign-conversion)
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g3 -DDEBUG -fno-omit-frame-pointer")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG")
# LTO: -flto=thin (Clang), -flto=auto (GCC)
# ASAN: -fsanitize=address -fno-omit-frame-pointer + add_link_options
# UBSAN: -fsanitize=undefined
# TSAN: -fsanitize=thread  (cannot combine with ASAN)
# Coverage: --coverage -O0 -g
```

**MSVC block:** `/W4`, `/O2`, `/GL /LTCG`, `/fsanitize=address`

**Feature checks:** Use `check_cxx_source_compiles()` to detect `HAVE_THREAD_LOCAL` etc., then stamp `cmake/features.h.in` → `build/generated/features.h`.

### Step 2.4 — `cmake/features.h.in`

```c
#pragma once
#cmakedefine HAVE_THREAD_LOCAL    1
#cmakedefine HAVE_CONSTEXPR_CMATH 1
```

### Step 2.5 — Verification

```bash
cmake --preset dev   # Should succeed with no errors
ls build/dev/generated/config.h   # Should exist
```

```bash
git add cmake/options.cmake cmake/compiler.cmake cmake/features.h.in config.h.in
git commit -m "Day 2: options and compiler modules"
```

---

## Phase 3 — Platform & Dependencies Modules  *(Day 3)*

### Step 3.1 — `cmake/platform.cmake`

**Platform detection:**
```cmake
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")  → set(PLATFORM_LINUX TRUE)
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin") → set(PLATFORM_MACOS TRUE)
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")→ set(PLATFORM_WINDOWS TRUE)
```

**Architecture detection:** Check `CMAKE_SYSTEM_PROCESSOR` for x86_64, aarch64, armv7.

**I/O backend detection:** Use `check_cxx_source_compiles()`:
- Linux: compile a snippet with `<sys/epoll.h>` → `HAVE_EPOLL`
- macOS: compile a snippet with `<sys/event.h>` → `HAVE_KQUEUE`

**ccache detection:**
```cmake
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
```

**CPU count:** `include(ProcessorCount)` → `ProcessorCount(NPROC)`

### Step 3.2 — `cmake/dependencies.cmake`

The pattern for every dependency:

```cmake
macro(find_or_fetch_libname)
    find_package(libname CONFIG QUIET)
    if(libname_FOUND)
        add_library(MyProject::libname ALIAS libname::libname)
    else()
        FetchContent_Declare(libname GIT_REPOSITORY ... GIT_TAG ... GIT_SHALLOW TRUE)
        FetchContent_MakeAvailable(libname)
        add_library(MyProject::libname ALIAS libname)
    endif()
endmacro()
```

**Dependencies list:**
1. `Threads` — always `find_package(Threads REQUIRED)`
2. `fmt` — v10.2.1
3. `spdlog` — v1.14.1
4. `GoogleTest` — **always FetchContent** (never system) to guarantee static linking and avoid macOS rpath/dylib ABI issues
5. `benchmark` — v1.8.3 (only if `BUILD_BENCHMARKS`)
6. `OpenSSL` — system only (no fallback), sets `MyProject_HAVE_SSL`
7. `ZLIB` — system only (no fallback), sets `MyProject_HAVE_ZLIB`

> **Critical lesson learned:** Never use system GTest on macOS when it was installed via conda/miniconda — it's a dylib without a correct rpath. Always use `FetchContent` for GTest and set `INSTALL_GTEST OFF` to prevent it from installing.

```bash
git add cmake/platform.cmake cmake/dependencies.cmake
git commit -m "Day 3: platform detection and dependency management"
```

---

## Phase 4 — Testing & Helper Macros  *(Day 4)*

### Step 4.1 — `cmake/testing.cmake`

**Must call `enable_testing()` first.**

Provide a `add_gtest()` function:

```cmake
function(add_gtest TEST_NAME)
    cmake_parse_arguments(TEST "" "TIMEOUT;LABELS" "DEPENDENCIES" ${ARGN})
    # TEST_UNPARSED_ARGUMENTS = source files
    add_executable(${TEST_NAME} ${TEST_SOURCES})
    target_link_libraries(${TEST_NAME} PRIVATE MyProject::gtest_main ${TEST_DEPENDENCIES})
    target_include_directories(${TEST_NAME} PRIVATE
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/tests>"
        "$<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/generated>"
    )
    target_compile_features(${TEST_NAME} PRIVATE cxx_std_20)
    add_test(NAME ${TEST_NAME} COMMAND ${TEST_NAME})
    set_tests_properties(${TEST_NAME} PROPERTIES TIMEOUT ${TEST_TIMEOUT} LABELS "${TEST_LABELS}")
endfunction()
```

Also provide `add_benchmark()` and an lcov `coverage` custom target.

### Step 4.2 — `cmake/Utils.cmake`

Two main functions:

**`add_project_library(name [STATIC|SHARED|INTERFACE|OBJECT] SOURCES ... PUBLIC_INCLUDES ... DEPENDENCIES ...)`**

> **Critical:** Public include directories must use generator expressions:
> ```cmake
> "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
> "$<INSTALL_INTERFACE:include>"
> ```
> Without this, CMake's "generate" step will error with "path prefixed in source/build directory".

Automatically creates a `MyProject::name` alias.

**`add_project_executable(name SOURCES ... DEPENDENCIES ... INCLUDES ...)`**

Also:
- `target_enable_unity_build(target)` — sets `UNITY_BUILD ON`
- `target_enable_pch(target pch_file)` — sets `target_precompile_headers`
- `target_enable_sanitizers(target)` — applies globally-enabled sanitizers per-target
- `target_add_feature(target FEATURE)` — adds `PROJECT_HAVE_FEATURE=1` definition

### Step 4.3 — Create test files

- `tests/test_smoke.cpp` — pure GoogleTest, no external deps
- `tests/core/test_core.cpp` — tests `core::Version`, `core::Result<T>`
- `tests/network/test_network.cpp` — tests `Server` lifecycle
- `tests/CMakeLists.txt` — calls `add_gtest()` for each

### Step 4.4 — Verification

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset dev --output-on-failure
# Expected: 100% tests passed, 0 failed out of 3
```

```bash
git add cmake/testing.cmake cmake/Utils.cmake tests/
git commit -m "Day 4: testing and helper macros"
```

---

## Phase 5 — Source Targets & Install/Package  *(Day 5)*

### Step 5.1 — C++ source files

**`src/core/include/core/version.h`** — exposes version constants from `config.h` via `inline constexpr`.

**`src/core/include/core/types.h`** — `Result<T>` template, `BufferView` typedef.

**`src/core/src/version.cpp`** — implements `get_version()`.

**`src/network/include/network/server.h`** — `Server` class (non-copyable, non-movable).

**`src/network/src/server.cpp`** — implements `Server::start()` / `Server::stop()` using spdlog.

**`src/app/main.cpp`** — wires everything together with fmt + spdlog.

### Step 5.2 — `src/CMakeLists.txt`

```cmake
add_project_library(core STATIC
    SOURCES core/src/version.cpp
    PUBLIC_INCLUDES core/include)

add_project_library(network STATIC
    SOURCES network/src/server.cpp
    PUBLIC_INCLUDES network/include
    DEPENDENCIES core MyProject::spdlog)

add_project_executable(myapp
    SOURCES app/main.cpp
    DEPENDENCIES core network MyProject::fmt MyProject::spdlog ${PLATFORM_LIBRARIES})
```

### Step 5.3 — `cmake/install.cmake`

```cmake
include(GNUInstallDirs)
install(TARGETS myapp core network EXPORT MyProjectTargets ...)
install(DIRECTORY src/core/include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/myproject ...)
include(CMakePackageConfigHelpers)
configure_package_config_file(cmake/MyProjectConfig.cmake.in ...)
write_basic_package_version_file(... COMPATIBILITY SameMajorVersion)
install(EXPORT MyProjectTargets NAMESPACE MyProject:: ...)
```

### Step 5.4 — `cmake/MyProjectConfig.cmake.in`

```cmake
@PACKAGE_INIT@
include("${CMAKE_CURRENT_LIST_DIR}/MyProjectTargets.cmake")
check_required_components(MyProject)
```

### Step 5.5 — `cmake/packaging.cmake`

Set CPack variables then `include(CPack)`. Select generators based on `PACKAGE_TGZ`, `PACKAGE_DEB`, etc.

### Step 5.6 — Verification

```bash
cmake --preset release
cmake --build --preset release
cmake --install build/release --prefix ./test-install
ls test-install/bin test-install/lib test-install/include
```

```bash
git add src/ cmake/install.cmake cmake/packaging.cmake cmake/MyProjectConfig.cmake.in
git commit -m "Day 5: source targets, install, packaging"
```

---

## Phase 6 — Documentation & Examples  *(Day 6)*

### Step 6.1 — `docs/Doxyfile.in`

Use `@PROJECT_NAME@`, `@PROJECT_VERSION@`, `@CMAKE_BINARY_DIR@` placeholders so CMake fills them in at configure time via `configure_file()`. The `add_custom_target(docs ...)` in `CMakeLists.txt` runs doxygen on the generated `Doxyfile`.

### Step 6.2 — `examples/basic_server/main.cpp`

Demonstrates `myproject::Server` usage — start, wait for Enter, stop.

### Step 6.3 — `examples/CMakeLists.txt`

```cmake
add_project_executable(basic_server
    SOURCES basic_server/main.cpp
    DEPENDENCIES core network MyProject::fmt MyProject::spdlog ${PLATFORM_LIBRARIES})
```

### Step 6.4 — `benchmarks/benchmark_throughput.cpp`

Uses `BENCHMARK(fn)` macro + `BENCHMARK_MAIN()`. Exercises `get_version()` and string construction.

### Step 6.5 — `.clang-format`

```yaml
BasedOnStyle:   Google
IndentWidth:    4
ColumnLimit:    100
```

```bash
git add docs/ examples/ benchmarks/ .clang-format README.md
git commit -m "Day 6: documentation, examples, benchmarks"
```

---
---

## Phase 8 — CI/CD Automation & GitHub Integration *(Day 8)*

### Step 8.1 — GitHub Secrets & PAT
If you want the workflows to push to other repositories or perform actions requiring higher permissions, add your **GitHub PAT** as a secret named `MY_GITHUB_PAT`. 
By default, the workflows use the built-in `${{ secrets.GITHUB_TOKEN }}` which is sufficient for:
- Creating releases on the current repo.
- Publishing to GitHub Pages on the current repo.

### Step 8.2 — Automated Releases (`release.yml`)
The project is configured to automatically create a GitHub Release whenever you push a version tag (e.g., `git tag v1.1.0 && git push --tags`).
- **Builds** in Release mode.
- **Packages** the binaries into a `.tar.gz` using CPack.
- **Uploads** the package to the new Release.

### Step 8.3 — API Documentation (`docs.yml`)
Every push to `main` triggers the documentation workflow:
- **Generates** HTML documentation using Doxygen.
- **Publishes** the results to the `gh-pages` branch.
- **View it at:** `https://<user>.github.io/<repo>/`

### Step 8.4 — Validation Pipeline
The `ci.yml` now includes a `validation` job that runs `scripts/validate.sh`. This ensures that:
1. Dev build + tests pass.
2. Release build succeeds.
3. Examples build correctly.
4. Install logic works.
5. CPack can generate a valid package.

---

## Phase 7 — CI/CD & Validation Scripts  *(Day 7)*

### Step 7.1 — `.github/workflows/ci.yml`

Three jobs:

1. **`build`** — matrix `[ubuntu-22.04, macos-13] × [Debug, Release]`
   - Install: ninja (+ lcov on Linux)
   - Steps: `cmake -B build -G Ninja`, `cmake --build`, `ctest`
   - On Linux Release: upload `myapp` as artifact

2. **`sanitizers`** — Ubuntu only
   - Configure with `ENABLE_ASAN=ON ENABLE_UBSAN=ON`
   - Build and test

3. **`coverage`** — Ubuntu only
   - Configure with `ENABLE_COVERAGE=ON`
   - Run lcov + genhtml, upload to Codecov

### Step 7.2 — Helper scripts

All scripts start with `set -euo pipefail` for safety.

| Script | Purpose |
|--------|---------|
| `scripts/clean.sh` | `rm -rf build build-* test-install _deps` |
| `scripts/format.sh` | `find src tests examples benchmarks | xargs clang-format -i` |
| `scripts/run-tests.sh` | `cmake --preset dev && cmake --build --preset dev && ctest --preset dev` |
| `scripts/validate.sh` | Full pipeline: dev build → release build → examples → install → cpack |

```bash
chmod +x scripts/*.sh
```

### Step 7.3 — `LICENSE`

MIT license text.

### Step 7.4 — Final commit and tag

```bash
git add -A
git commit -m "Day 7: CI/CD, validation scripts, license"
git tag -a v1.0.0 -m "Production-ready CMake template v1.0.0"
```

---

## Quick Verification Checklist

Run these after building to confirm everything works:

```bash
# 1. Clean configure
cmake --preset dev

# 2. Build all
cmake --build --preset dev

# 3. All tests pass
ctest --preset dev --output-on-failure
# Expected: 100% tests passed, 0 failed out of 3

# 4. Release build
cmake --preset release && cmake --build --preset release

# 5. Install test
cmake --install build/release --prefix ./test-install
ls test-install/bin/myapp
ls test-install/lib/cmake/MyProject/

# 6. Package
cpack --config build/release/CPackConfig.cmake -B build/release/packages
ls build/release/packages/

# 7. Examples (optional)
cmake --preset dev -DBUILD_EXAMPLES=ON
cmake --build --preset dev
./build/dev/basic_server
```

---

## Key Design Decisions & Lessons Learned

| Decision | Rationale |
|----------|-----------|
| **Always `FetchContent` for GTest** | System GTest on macOS (conda) is a dylib with broken rpath — static linking from source avoids it |
| **Generator expressions for `target_include_directories`** | CMake errors out if you pass raw absolute paths to PUBLIC include dirs of installable targets — must use `$<BUILD_INTERFACE:...>` and `$<INSTALL_INTERFACE:...>` |
| **`Utils.cmake` included before `add_subdirectory(src)`** | `add_project_library()` is called inside `src/CMakeLists.txt` so it must be defined before that directory is processed |
| **Namespace alias `MyProject::name`** | Allows consuming projects to use the same `target_link_libraries` syntax whether they built from source or installed the package |
| **`INSTALL_GTEST OFF`** | Prevents GTest from polluting the install prefix |
| **`GIT_SHALLOW TRUE`** | FetchContent clones only the tagged commit — much faster on CI |

---

## File Map (Final Structure)

```
cmake-template/
├── CMakeLists.txt               Root orchestrator
├── CMakePresets.json            dev / dev-asan / release / ci
├── config.h.in                  Stamped → build/generated/config.h
├── .gitignore
├── .clang-format
├── LICENSE
├── README.md
│
├── cmake/
│   ├── options.cmake            All option() + configure_file()
│   ├── compiler.cmake           Flags, sanitizers, LTO, coverage
│   ├── platform.cmake           OS/arch, epoll/kqueue, ccache
│   ├── dependencies.cmake       find-or-fetch for all deps
│   ├── testing.cmake            enable_testing(), add_gtest()
│   ├── install.cmake            GNUInstallDirs + CMake package export
│   ├── packaging.cmake          CPack generators
│   ├── Utils.cmake              add_project_library/executable macros
│   ├── features.h.in            → build/generated/features.h
│   └── MyProjectConfig.cmake.in → installed MyProjectConfig.cmake
│
├── src/
│   ├── CMakeLists.txt
│   ├── core/
│   │   ├── include/core/version.h   types.h
│   │   └── src/version.cpp
│   ├── network/
│   │   ├── include/network/server.h
│   │   └── src/server.cpp
│   └── app/main.cpp
│
├── tests/
│   ├── CMakeLists.txt
│   ├── test_smoke.cpp
│   ├── core/test_core.cpp
│   └── network/test_network.cpp
│
├── benchmarks/
│   ├── CMakeLists.txt
│   └── benchmark_throughput.cpp
│
├── examples/
│   ├── CMakeLists.txt
│   └── basic_server/main.cpp
│
├── docs/Doxyfile.in
├── scripts/
│   ├── clean.sh
│   ├── format.sh
│   ├── run-tests.sh
│   └── validate.sh
└── .github/workflows/ci.yml
```