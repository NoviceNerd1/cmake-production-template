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
- [x] **Optimization**: LTO/IPO, Unity Builds, and Precompiled Headers (PCH) support.

### 2. Platform & Logic
- [x] **Platform Detection**: Automatic detection of OS (Linux, macOS, Windows) and architecture.
- [x] **I/O Backends**: Detection for `epoll` (Linux) and `kqueue` (macOS).
- [x] **Dependency Management**: Hybrid "find-or-fetch" strategy (fmt, spdlog, benchmark).
- [x] **Testing Framework**: Hard-locked GoogleTest via FetchContent for reproducibility.
- [x] **Core Utility Macros**: `add_project_library` and `add_project_executable` with automatic namespace aliasing.
- [x] **Project Initializer**: Created `scripts/init_project.sh` to automatically rebrand the template for new projects.

### 3. Source & Distribution
- [x] **Modular Source**: Implementation of `core`, `network`, and `app` targets.
- [x] **Unit Testing**: Modular tests for all libraries (`tests/`).
- [x] **Benchmarking**: Micro-benchmarks implemented using Google Benchmark (`benchmarks/`).
- [x] **Examples**: Standalone usage demonstration (`examples/`).
- [x] **Installation**: Standard GNU layout (`GNUInstallDirs`) with CMake package exports.
- [x] **Packaging**: CPack configuration for TGZ, DEB, and RPM.

### 4. CI/CD & Automation
- [x] **Validation Suite**: Local pipeline emulation via `scripts/validate.sh`.
- [x] **Continuous Integration**: GitHub Actions matrix build (Ubuntu/macOS) with ASAN and Coverage.
- [x] **Automated Releases**: Workflow to build, package, and create GitHub Releases on tag push (`v*`).
- [x] **Auto-Documentation**: GitHub Pages deployment for Doxygen API docs on push to `main`.

---

## 🛠 To-be-Implemented (Roadmap)

### Priority 1: Project Tooling
- [ ] **Codegen Content**: Populate `tools/codegen` with a sample Python script for generating boilerplate (e.g., error codes).
- [ ] **Debug Helpers**: Populate `tools/debug` with `.gdbinit` or `.lldbinit` optimized for the project structure.

### Priority 2: Advanced Build Features
- [ ] **Package Manager Integration**: Add formal support for `vcpkg` or `Conan` in `cmake/dependencies.cmake`.
- [ ] **Cross-Compilation**: Add toolchain files for ARM/Embedded targets.
- [ ] **PGO Automation**: Implement a two-pass build workflow for Profile-Guided Optimization.

### Priority 3: Aesthetics & UX
- [ ] **Premium Doxygen**: Add custom CSS/HTML header to Doxygen for a modern, branded look (currently uses default FOREST).
- [ ] **Build Timing**: Add a post-build hook to report time spent in different build stages (as per Plan 17.3).

---

## 📈 Long-Term Evolution (Months 10-12)
- [ ] **Bazel Migration Guide**: Documentation for transitioning to Bazel for monorepo scale.
- [ ] **Multi-CI Support**: Add templates for GitLab CI and Azure DevOps pipelines.
- [ ] **CUDA Support**: Optional integration for high-performance GPU compute modules.
