# How-To: Build a Production CMake Template From Scratch

> Step-by-step reproduction guide — every command and file I created, in exact order.

---

## Phase 1 — Scaffolding & Configuration (Day 1-2)

### 1.1 Directory Structure
Create the following structure to ensure modularity:
```bash
mkdir -p src/core/include/myproject/core src/core/src
mkdir -p src/network/include/myproject/network src/network/src
mkdir -p tests/core tests/network benchmarks examples/basic_server
mkdir -p cmake/FindModules docs scripts .github/workflows
```

### 1.2 Root Orchestrator
Create `CMakeLists.txt` in the root. It should include modular `.cmake` files from the `cmake/` directory.

### 1.3 Presets
Create `CMakePresets.json` to define your build environments:
- `dev`: Debug, tests ON.
- `release`: Release, LTO ON, tests OFF.
- `ci`: RelWithDebInfo, sanitizers ON.

---

## Phase 2 — Compiler & Build Logic (Day 3-4)

### 2.1 Compiler Standards (`cmake/compiler.cmake`)
- Set `CMAKE_CXX_STANDARD 20`.
- Define `PROJECT_WARNING_FLAGS` for strict internal checks.
- **Critical**: Do not apply warnings globally via `add_compile_options`; apply them to project targets only.

### 2.2 Platform Logic (`cmake/platform.cmake`)
- Detect Linux (`epoll`), macOS (`kqueue`), or Windows.
- Hook `ccache` to `CMAKE_CXX_COMPILER_LAUNCHER`.

### 2.3 Dependency Strategy (`cmake/dependencies.cmake`)
- Use a "Find-or-Fetch" pattern.
- Always use `FetchContent` for `GoogleTest` to avoid ABI/rpath issues.

---

## Phase 3 — Target Definitions (Day 5-6)

### 3.1 Project Macros (`cmake/Utils.cmake`)
Define `add_project_library` and `add_project_executable`.
- Ensure they apply `PROJECT_WARNING_FLAGS`.
- Use generator expressions for includes: `$<BUILD_INTERFACE:...>` and `$<INSTALL_INTERFACE:include>`.

### 3.2 Hierarchical Includes
Source headers should be at `include/myproject/<module>/<header>.h`.
This ensures developers and consumers use identical syntax:
```cpp
#include <myproject/core/version.h>
```

### 3.3 Unity Builds
Activate Unity builds for libraries to speed up compilation:
```cmake
target_enable_unity_build(core)
```

---

## Phase 4 — Automation & CI/CD (Day 7-9)

### 4.1 Validation Script (`scripts/validate.sh`)
Create a script that cleans, builds, and tests everything (Dev, Release, Examples, Benchmarks, Install).
**Tip**: Use `set -euo pipefail` but handle counter increments as `PASS=$((PASS + 1))` to avoid zero-exit status issues.

### 4.2 GitHub Workflows
- **`ci.yml`**: Matrix builds for Linux/macOS.
- **`release.yml`**: Auto-packages and creates a GitHub Release on tag push.
- **`docs.yml`**: Builds Doxygen and deploys to GitHub Pages on push to `main`.

### 4.3 Rebranding (`scripts/init_project.sh`)
Create a portable script to rename the project:
- Detect OS (`darwin` vs `linux`).
- Use `sed -i` (Linux) or `sed -i ''` (macOS) to replace project strings.

---

## Final Verification
1.  Run `./scripts/validate.sh`.
2.  Check `build/release/packages` for generated tarballs.
3.  Open `build/docs/html/index.html` to verify API documentation.

**Your Production CMake Template is now complete and verified.**