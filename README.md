# Platinum Grade CMake Production Template

[![CI](https://img.shields.io/badge/CI-GitHub%20Actions-blue?style=flat-square&logo=github-actions)](.github/workflows)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)
[![C++](https://img.shields.io/badge/C%2B%2B-20-blue?style=flat-square&logo=c%2B%2B)](https://en.cppreference.com/w/cpp/20)
[![CMake](https://img.shields.io/badge/CMake-3.21%2B-red?style=flat-square&logo=cmake)](https://cmake.org/)

A battle-hardened, enterprise-ready C++ build system template designed for high-performance, modularity, and seamless developer experience. This template eliminates months of build-system engineering by providing a ready-to-use foundation following industry best practices.

---

## Key Value Propositions

*   **Zero Boilerplate**: Start coding your logic immediately; the build system, dependency management, and CI/CD are already handled.
*   **Performance First**: Native support for **Unity Builds**, **ccache**, and **Link-Time Optimization (LTO)** for lightning-fast compilation.
*   **Robust Lifecycle**: Built-in **Graceful Shutdown** handling (SIGINT/SIGTERM) and type-safe `Result<T>` error management.
*   **Professional Standards**: C++20 `std::string_view` versioning, hierarchical includes, and full **CPack** support.

---

## Table of Contents
- [Architecture Deep-Dive](#architecture-deep-dive)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Build & Use](#build--use)
- [Developer Workflow](#developer-workflow)
- [CI/CD & Automation](#cicd--automation)
- [Project Structure](#project-structure)
- [License](#license)

---

## Architecture Deep-Dive

This project follows a **Target-Centric** build philosophy, ensuring that logic is decoupled and reusable.

### The Engine (`cmake/`)
Modular CMake scripts that encapsulate complex logic:
- `compiler.cmake`: Hardened security flags, compiler-specific optimizations, and warning levels.
- `dependencies.cmake`: A robust "Find-or-Fetch" system that integrates `fmt`, `spdlog`, `googletest`, and `benchmark` with automatic fallback to `FetchContent`.
- `Utils.cmake`: High-level macros (`add_project_library`, `add_project_executable`) that enforce project standards automatically.

### The Heart (`src/`)
Source code is organized into discrete modules. We enforce **Prefixed Includes**, ensuring that internal project headers are always scoped (e.g., `#include <project/module/header.h>`). This prevents naming collisions and makes the codebase easier to navigate.

### The Guard (`tests/` & `benchmarks/`)
Integrated unit testing via **GoogleTest** and performance benchmarking via **Google Benchmark**. Tests are treated as first-class citizens and are integrated into the standard `ctest` workflow.

---

## Prerequisites

Ensure you have the following installed:
- **CMake**: 3.21 or higher
- **Compiler**: GCC 11+, Clang 13+, or AppleClang 13+ (Must support C++20)
- **ccache**: (Optional, highly recommended for build speed)
- **Doxygen**: (Optional, for documentation generation)

---

## Getting Started

### 1. Clone the Template
```bash
git clone https://github.com/NoviceNerd1/cmake-production-template.git my-project
cd my-project
```

### 2. Rebrand Your Project
Use the included automated script to rename all project-specific strings (CMake logic, header paths, namespaces):
```bash
./scripts/init_project.sh MyNewProject
```

---

## Build & Use

We utilize **CMake Presets** to simplify the configuration and build process across different environments.

### Development Build (Debug + Tests)
Ideal for daily development with full debug symbols and unit tests enabled.
```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset dev
```

### Production Build (Release + LTO)
Generates highly optimized binaries with Link-Time Optimization and Unity builds enabled.
```bash
cmake --preset release
cmake --build --preset release
```

### Security/Quality Build (Sanitizers)
Builds with Address, Undefined Behavior, and Thread sanitizers enabled.
```bash
cmake --preset ci
cmake --build --preset ci
```

---

## Developer Workflow

### Adding a New Library
1. Create your directory in `src/`.
2. Use the `add_project_library` macro in your `CMakeLists.txt`:
   ```cmake
   add_project_library(NAME mymodule 
       SOURCES src/file.cpp 
       PUBLIC_DEPS fmt::fmt 
   )
   ```

### Formatting Code
Maintain a consistent style across the codebase using the provided script:
```bash
./scripts/format.sh
```

### Full Validation
Before pushing, run the comprehensive validation script which mirrors the CI pipeline (Clean, Build, Test, Benchmark, Package):
```bash
./scripts/validate.sh
```

---

## CI/CD & Automation

The repository includes a comprehensive GitHub Actions suite:
- **CI**: Validates every PR/Commit on Linux and macOS across multiple compilers.
- **Documentation**: Automatically builds Doxygen documentation and deploys it to GitHub Pages.
- **Release**: Upon tagging a version (e.g., `v1.0.0`), it automatically generates release artifacts (DEB, RPM, TGZ) and creates a GitHub Release.

---

## Project Structure

```bash
.
├── .github/             # GitHub Actions Workflows
├── cmake/               # Modular build logic (The Engine)
├── src/                 # Hierarchical source code (The Heart)
│   ├── core/            # Foundation library
│   ├── network/         # Specialized network module
│   └── app/             # Application entry point
├── tests/               # Unit testing suite (The Guard)
├── benchmarks/          # Performance benchmarks (The Scale)
├── examples/            # Usage demonstrations
├── scripts/             # Automation & Maintenance tools
├── Docs/                # Deep-dive technical guides
└── CMakePresets.json    # Standardized build configurations
```

---

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for the full text.

---

<p align="center">Built with support for the C++ Community by <b>NoviceNerd</b></p>
