# Project Status & To-Do List

> Status of the Production CMake Template implementation against the [Plan.md](./Plan.md) and [Execution.md](./Execution.md).

---

## ✅ Completed (Production Ready)

### 1. Build Core Infrastructure
- [x] **Project Scaffolding**: Standard directory structure (src, include, tests, benchmarks, etc.)
- [x] **Root Orchestrator**: High-performance `CMakeLists.txt` with modular includes.
- [x] **Presets**: `CMakePresets.json` with `dev`, `dev-asan`, `release`, and `ci` configurations.
- [x] **Compiler Module**: Hardened flags for GCC, Clang, and MSVC.
- [x] **Sanitizers**: Integrated ASAN, UBSAN, and TSAN support.
- [x] **LTO/IPO**: Link-time optimization enabled globally in `compiler.cmake`.
- [x] **Project Initializer**: Created `scripts/init_project.sh` with cross-platform `sed` support.
- [x] **Unity Builds**: Integrated and activated for `core` and `network` libraries.

### 2. Platform & Logic
- [x] **Platform Detection**: Automatic detection of OS (Linux, macOS, Windows) and architecture.
- [x] **I/O Backends**: Detection for `epoll` (Linux) and `kqueue` (macOS).
- [x] **Dependency Management**: Hybrid "find-or-fetch" strategy (fmt, spdlog, benchmark).
- [x] **Testing Framework**: Hard-locked GoogleTest via FetchContent.
- [x] **Core Utility Macros**: `add_project_library` and `add_project_executable` with namespace aliasing.

### 3. Source & Distribution
- [x] **Modular Source**: Implementation of `core`, `network`, and `app` targets.
- [x] **Unit Testing**: Modular tests for all libraries (`tests/`).
- [x] **Benchmarking**: Micro-benchmarks implemented using Google Benchmark (`benchmarks/`).
- [x] **Installation**: Standard GNU layout (`GNUInstallDirs`) with CMake package exports.
- [x] **Packaging**: CPack configuration for TGZ, DEB, and RPM.

### 4. CI/CD & Automation
- [x] **Validation Suite**: Local pipeline emulation via `scripts/validate.sh` (includes Benchmark checks).
- [x] **Continuous Integration**: GitHub Actions matrix build with ASAN and Coverage.
- [x] **Automated Releases**: Workflow to build, package, and create GitHub Releases on tag.
- [x] **Auto-Documentation**: GitHub Pages deployment for API docs.

---

## 🛠 To-be-Improved (Refinement Phase)

### 1. Build System Polish
- [ ] **Activate PCH**: Call `target_enable_pch()` in `src/CMakeLists.txt` for stable headers.
- [ ] **Standardize Include Prefixes**: Refactor source structure to use `include/myproject/...` so that internal and external `#include` statements are identical (e.g. `<myproject/core/version.h>`).
- [ ] **Static Analysis Integration**: Hook `ENABLE_CLANG_TIDY` and `ENABLE_CPPCHECK` into targets via `set_target_properties`.

### 2. Documentation & Quality
- [ ] **Premium Doxygen Styling**: Integrate a modern CSS theme (like [m.css](https://mcss.mosra.cz/)) for a more professional API reference.
- [ ] **Warning Hygiene**: Audit remaining `AppleClang` warnings in GoogleTest headers (already suppressed in some places).

---

## 🚀 New Features (Advanced Phase)

### 1. Tooling & Productivity
- [ ] **Codegen Content**: Implement a sample Python generator in `tools/codegen` for automated boilerplate (e.g., error codes).
- [ ] **Debug Pretty-Printers**: Add GDB/LLDB scripts in `tools/debug` for visualizing project-specific types.
- [ ] **Automated Versioning**: Script to bump version in `CMakeLists.txt` and create a git tag.

### 2. Roadmap Features
- [ ] **Package Manager Support**: Formalize integration for `vcpkg` and `Conan`.
- [ ] **Cross-Compilation**: Add toolchain profiles for ARM/Embedded targets.
- [ ] **PGO Workflow**: Add a preset for Profile-Guided Optimization builds.
