# Technical Walk-Through: Production CMake Template

This document provides a guided tour of the architecture and design decisions behind the Platinum Grade CMake build system.

---

## 1. Modular Architecture (`cmake/*.cmake`)
Rather than a monolithic `CMakeLists.txt`, the build logic is decoupled into specialized modules:
- **`options.cmake`**: User-facing features, feature flags, and `config.h` generation.
- **`compiler.cmake`**: Hardened flags, sanitizers, and optimization (LTO/IPO).
- **`dependencies.cmake`**: Smart "Find-or-Fetch" logic ensuring builds work whether offline or online.
- **`Utils.cmake`**: The "API" of the build system, providing `add_project_library` and `add_project_executable`.

## 2. The "Prefix" include Standard
To match professional libraries like Boost or LLVM, all includes use a namespace prefix:
```cpp
#include <myproject/core/version.h>
```
This is achieved by a hierarchical directory structure under `src/<module>/include/myproject/` and using `$<BUILD_INTERFACE>` / `$<INSTALL_INTERFACE>` generator expressions.

## 3. Build Acceleration
The template implements three layers of speed optimization:
1.  **Unity Builds**: Merging translation units to reduce compiler overhead (activated in `src/CMakeLists.txt`).
2.  **ccache Integration**: Automatic detection and usage of compiler caching (`platform.cmake`).
3.  **Precompiled Headers (PCH)**: Macro support for stable system headers (`Utils.cmake`).

## 4. Quality Gates & Validation
- **Isolated Warnings**: Strict warnings (`-Wconversion`, `-Wshadow`) are applied **only** to project targets. This prevents third-party code from breaking your build while keeping your code pristine.
- **Local Validation**: The `scripts/validate.sh` script exactly mirrors the CI environment, allowing developers to catch build, test, benchmark, or install issues before pushing.

## 5. CI/CD Pipeline
- **Continuous Integration**: Multi-platform matrix (Linux, macOS) testing Debug/Release and ASAN.
- **Auto-Release**: Pushing a tag (e.g., `v1.0.0`) triggers a build that creates a GitHub Release and uploads CPack-generated tarballs.
- **Auto-Docs**: Push to `main` builds Doxygen and deploys to GitHub Pages via an automated workflow.

---

## 6. Project Rebranding
The `scripts/init_project.sh` tool allows instant transformation of this template into a new project:
```bash
./scripts/init_project.sh MyNewApp
```
It handles the string replacement across CMake and source files, and is portable between macOS and Linux.

---

**This template is designed to be the "Last Build System You'll Ever Need" for modern C++ projects.**