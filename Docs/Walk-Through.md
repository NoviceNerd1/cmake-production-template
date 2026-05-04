# Technical Walk-Through: A Tour of the Build System

Welcome to the internal technical walk-through of the Platinum Grade CMake Build System. This document explains the "magic" behind the modularity and performance of the template.

---

## 1. The Entry Point: `CMakeLists.txt` & Presets
The root `CMakeLists.txt` is an orchestrator. It doesn't define targets itself but includes specialized modules from the `cmake/` directory.

- **`CMakePresets.json`**: This is your interface. It defines standard flags and binary directories.
  - `dev`: High-speed development with testing.
  - `ci`: RelWithDebInfo with sanitizers for deep validation.
  - `release`: Max optimization with LTO and no tests.

## 2. The Module Layer (`cmake/`)
Each file has a single responsibility:
- **`compiler.cmake`**: Detects if you are using GCC, Clang, or MSVC. It defines `PROJECT_WARNING_FLAGS`—the "Strict Mode" for your code.
- **`dependencies.cmake`**: Implements the **Find-or-Fetch** pattern. It checks if `fmt` or `spdlog` are on your system; if not, it clones them from GitHub.
- **`Utils.cmake`**: The core API. It provides `add_project_library()`, which automatically handles include paths, namespaces, and warning applications.

## 3. The "Prefix" include Standard
To prevent include collisions, we use the "Prefix" standard.
- **Source**: `src/core/include/myproject/core/version.h`
- **Usage**: `#include <myproject/core/version.h>`
This is managed via CMake generator expressions in `Utils.cmake`:
```cmake
"$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
"$<INSTALL_INTERFACE:include>"
```

## 4. Performance: Unity Builds & ccache
We use two main tools to kill compile times:
1.  **Unity Builds**: We merge small `.cpp` files into one "Unity" file during compilation. This reduces the number of times the compiler has to parse header files.
2.  **ccache**: If you build the same code twice (even after a clean), `ccache` serves the cached object files instantly.

## 5. Reliability: The Validation Pipeline
The `scripts/validate.sh` is our "CI-on-your-laptop". It runs:
1.  **Dev Build**: Fast check.
2.  **Release Build**: Optimization check.
3.  **Examples & Benchmarks**: API usage check.
4.  **Install & CPack**: Deployment check.

## 6. Project Rebranding
The `init_project.sh` script is a portable rebranding tool. It uses `sed` (detecting BSD vs GNU syntax) to swap "MyProject" with your actual project name across all source and build files.

---

## Summary
This system is designed to be **unbreakable**. By isolating 3rd-party warnings, standardizing includes, and automating the validation pipeline, we ensure that the build system is a productivity multiplier, not a maintenance burden.