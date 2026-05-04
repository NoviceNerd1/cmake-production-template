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
- [x] **Project Initializer**: Portable `scripts/init_project.sh` for rebranding.
- [x] **Unity Builds**: Integrated and activated for `core` and `network` libraries.
- [x] **Isolated Warnings**: Strict warnings (conversion, shadow, etc.) are applied only to internal targets, preventing breakages in 3rd-party dependencies.

### 2. Platform & Logic
- [x] **Platform Detection**: Automatic detection of OS (Linux, macOS, Windows) and architecture.
- [x] **I/O Backends**: Detection for `epoll` (Linux) and `kqueue` (macOS).
- [x] **Dependency Management**: Hybrid "find-or-fetch" strategy (fmt, spdlog, benchmark).
- [x] **Testing Framework**: Hard-locked GoogleTest via FetchContent.
- [x] **Core Utility Macros**: `add_project_library` and `add_project_executable` with namespace aliasing.

### 3. Source & Distribution
- [x] **Modular Source**: Implementation of `core`, `network`, and `app` targets.
- [x] **Hierarchical Includes**: Refactored to use standard library prefixes (`#include <myproject/core/...>`).
- [x] **Unit Testing**: Modular tests for all libraries (`tests/`).
- [x] **Benchmarking**: Micro-benchmarks implemented using Google Benchmark (`benchmarks/`).
- [x] **Installation**: Standard GNU layout (`GNUInstallDirs`) with CMake package exports.
- [x] **Packaging**: CPack configuration for TGZ, DEB, and RPM.

### 4. CI/CD & Automation
- [x] **Validation Suite**: Robust `scripts/validate.sh` covering Dev, Release, Examples, Benchmarks, Install, and CPack.
- [x] **Continuous Integration**: GitHub Actions matrix build with ASAN and Coverage.
- [x] **Automated Releases**: Workflow to build, package, and create GitHub Releases on tag.
- [x] **Auto-Documentation**: GitHub Pages deployment with enhanced Doxygen (Treeview, MathJax).

---

## 🛠 To-be-Improved (Refinement Phase)

### 1. Build System Polish
- [ ] **Activate PCH**: Call `target_enable_pch()` in `src/CMakeLists.txt` for stable headers.
- [ ] **Static Analysis Integration**: Hook `ENABLE_CLANG_TIDY` and `ENABLE_CPPCHECK` into targets via `set_target_properties`.

### 2. Documentation & Quality
- [ ] **Premium Doxygen Styling**: Integrate a modern CSS theme (like [m.css](https://mcss.mosra.cz/)) for a more professional API reference.
- [ ] **Warning Hygiene**: Audit remaining `AppleClang` warnings in GoogleTest headers (already suppressed in some places).

---

## 🚀 New Features (Advanced Phase)

### 1. Tooling & Productivity
- [ ] **Codegen Content**: Implement a sample Python generator in `tools/codegen` for automated boilerplate.
- [ ] **Debug Pretty-Printers**: Add GDB/LLDB scripts in `tools/debug` for visualizing project-specific types.
- [ ] **Automated Versioning**: Script to bump version in `CMakeLists.txt` and create a git tag.

### 2. Roadmap Features
- [ ] **Package Manager Support**: Formalize integration for `vcpkg` and `Conan`.
- [ ] **Cross-Compilation**: Add toolchain profiles for ARM/Embedded targets.
- [ ] **PGO Workflow**: Add a preset for Profile-Guided Optimization builds.
