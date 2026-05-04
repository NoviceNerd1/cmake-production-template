# MyProject — Production CMake Template

> A reusable, production-ready CMake build system template for modern C++ projects.

## Features

| Feature | Details |
|---------|---------|
| **CMake** | 3.20+ with presets (`CMakePresets.json`) |
| **C++ Standard** | C++20 (configurable) |
| **Compilers** | GCC 11+, Clang 15+, MSVC 2022 |
| **Platforms** | Linux, macOS, Windows |
| **Dependencies** | `fmt`, `spdlog`, `googletest`, `benchmark` — auto-fetched if not installed |
| **Sanitizers** | ASAN, UBSAN, TSAN — one flag to enable |
| **Testing** | GoogleTest + CTest with labels and timeouts |
| **Coverage** | `lcov` / `genhtml` report target |
| **Build acceleration** | Unity builds, precompiled headers, ccache |
| **Packaging** | CPack — TGZ, DEB, RPM |
| **CI/CD** | GitHub Actions (Linux + macOS matrix, ASAN, coverage) |

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/yourname/myproject.git && cd myproject

# 2. Configure (development)
cmake --preset dev

# 3. Build
cmake --build --preset dev

# 4. Run tests
ctest --preset dev

# 5. Run the binary
./build/dev/myapp
```

---

## Build Presets

| Preset | Type | Tests | Sanitizers | Notes |
|--------|------|-------|------------|-------|
| `dev` | Debug | ON | OFF | Daily development |
| `dev-asan` | Debug | ON | ASAN+UBSAN | Memory debugging |
| `release` | Release | OFF | OFF | Production binary |
| `ci` | RelWithDebInfo | ON | ASAN+UBSAN | Full CI pipeline |

```bash
cmake --preset release
cmake --build --preset release
```

---

## Directory Structure

```
.
├── CMakeLists.txt          Root orchestrator
├── CMakePresets.json       Build presets
├── config.h.in             Configuration header template
├── cmake/
│   ├── options.cmake       Feature flags & config.h generation
│   ├── compiler.cmake      Warnings, sanitizers, LTO, coverage
│   ├── platform.cmake      OS/arch detection, ccache, epoll/kqueue
│   ├── dependencies.cmake  fmt, spdlog, GTest, benchmark (find-or-fetch)
│   ├── testing.cmake       CTest helpers (add_gtest, coverage target)
│   ├── install.cmake       GNU install dirs, CMake package export
│   ├── packaging.cmake     CPack generators
│   ├── Utils.cmake         add_project_library / add_project_executable
│   └── MyProjectConfig.cmake.in  Consuming-project config template
├── src/
│   ├── core/               Core library (version, types)
│   ├── network/            Network library (Server)
│   └── app/                Main executable
├── tests/                  GoogleTest unit tests
├── benchmarks/             Google Benchmark micro-benchmarks
├── examples/               Usage examples
├── docs/                   Doxygen configuration
├── scripts/                Helper shell scripts
└── .github/workflows/      GitHub Actions CI
```

---

## CMake Options

| Option | Default | Description |
|--------|---------|-------------|
| `BUILD_TESTING` | ON | Build unit tests |
| `BUILD_BENCHMARKS` | OFF | Build Google Benchmarks |
| `BUILD_EXAMPLES` | OFF | Build example programs |
| `BUILD_DOCS` | OFF | Generate Doxygen docs |
| `ENABLE_LTO` | OFF | Link Time Optimisation |
| `ENABLE_UNITY_BUILD` | ON | Merge translation units (faster) |
| `ENABLE_ASAN` | OFF | AddressSanitizer |
| `ENABLE_UBSAN` | OFF | UndefinedBehaviorSanitizer |
| `ENABLE_TSAN` | OFF | ThreadSanitizer |
| `ENABLE_COVERAGE` | OFF | gcov / lcov instrumentation |
| `ENABLE_WARNINGS_AS_ERRORS` | OFF | `-Werror` / `/WX` |
| `PACKAGE_TGZ` | ON | CPack TGZ generator |
| `PACKAGE_DEB` | OFF | CPack DEB generator |

---

## Helper Scripts

```bash
./scripts/clean.sh       # Remove all build directories
./scripts/format.sh      # clang-format all sources
./scripts/run-tests.sh   # Build dev + run CTest
./scripts/validate.sh    # Full local pipeline validation
```

---

## Installation

```bash
cmake --preset release
cmake --build --preset release
cmake --install build/release --prefix /usr/local
```

Installed layout:
```
/usr/local/bin/myapp
/usr/local/lib/libcore.a
/usr/local/lib/libnetwork.a
/usr/local/lib/cmake/MyProject/MyProjectConfig.cmake
/usr/local/include/myproject/
```

Consuming projects:
```cmake
find_package(MyProject REQUIRED)
target_link_libraries(my_app PRIVATE MyProject::core)
```

---

## Documentation

```bash
cmake --preset dev -DBUILD_DOCS=ON
cmake --build --preset dev --target docs
open build/dev/docs/html/index.html
```

---

## Packaging

```bash
cpack --config build/release/CPackConfig.cmake -B build/release/packages
ls build/release/packages/
# MyProject-1.0.0-Darwin.tar.gz   (or Linux.tar.gz)
```

---
---

## CI/CD & Automation

The repository includes a comprehensive GitHub Actions suite:

- **CI (`ci.yml`)**: Matrix builds on Linux and macOS, testing across Debug/Release, AddressSanitizer checks, and code coverage reporting.
- **Releases (`release.yml`)**: Automatically generates a GitHub Release and uploads packaged binaries (`.tar.gz`) whenever a version tag (e.g., `v1.0.0`) is pushed.
- **Documentation (`docs.yml`)**: Automatically builds Doxygen API docs and publishes them to GitHub Pages on every push to `main`.
- **Validation**: Every CI run performs a full pipeline validation using `scripts/validate.sh`, emulating the local developer experience.

---

## License

MIT — see [LICENSE](LICENSE).
