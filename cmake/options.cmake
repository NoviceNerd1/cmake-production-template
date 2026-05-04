#=============================================================================
# Project Configuration Options
# All cache variables use the MYPROJECT_ prefix to avoid namespace collisions.
#=============================================================================

#-----------------------------------------------------------------------------
# Build Options
#-----------------------------------------------------------------------------
option(BUILD_TESTING         "Build unit tests"                          ON)
option(BUILD_BENCHMARKS      "Build performance benchmarks"              OFF)
option(BUILD_EXAMPLES        "Build example programs"                    OFF)
option(BUILD_DOCS            "Build Doxygen documentation"               OFF)
option(BUILD_SHARED_LIBS     "Build shared libraries instead of static"  OFF)

#-----------------------------------------------------------------------------
# Optimisation Options
#-----------------------------------------------------------------------------
option(ENABLE_LTO            "Enable Link Time Optimization"             OFF)
option(ENABLE_IPO            "Alias for LTO (Interprocedural Opt)"       OFF)
option(ENABLE_UNITY_BUILD    "Enable Unity/Jumbo builds (2-3x faster)"  ON)
option(ENABLE_PRECOMPILED_HEADERS "Enable Precompiled Headers"           ON)
option(ENABLE_CCACHE         "Use ccache compiler cache if available"    ON)

#-----------------------------------------------------------------------------
# Sanitizer Options  (only one active family at a time)
#-----------------------------------------------------------------------------
option(ENABLE_ASAN   "Enable AddressSanitizer"              OFF)
option(ENABLE_UBSAN  "Enable UndefinedBehaviorSanitizer"    OFF)
option(ENABLE_TSAN   "Enable ThreadSanitizer"               OFF)
option(ENABLE_LSAN   "Enable LeakSanitizer (part of ASAN)"  OFF)

#-----------------------------------------------------------------------------
# Code Quality Options
#-----------------------------------------------------------------------------
option(ENABLE_WARNINGS_AS_ERRORS  "Treat compiler warnings as errors"  OFF)
option(ENABLE_COVERAGE            "Enable code coverage (gcov/lcov)"   OFF)
option(ENABLE_CPPCHECK            "Run cppcheck static analyzer"        OFF)
option(ENABLE_CLANG_TIDY          "Run clang-tidy"                      OFF)

#-----------------------------------------------------------------------------
# Packaging Options
#-----------------------------------------------------------------------------
option(PACKAGE_TGZ   "Build tarball package (CPack)"     ON)
option(PACKAGE_DEB   "Build Debian package  (CPack)"     OFF)
option(PACKAGE_RPM   "Build RPM package     (CPack)"     OFF)
option(PACKAGE_NSIS  "Build Windows NSIS installer"      OFF)

#-----------------------------------------------------------------------------
# Performance Tuning (surfaced in config.h)
#-----------------------------------------------------------------------------
set(MAX_CONNECTION_COUNT  10000  CACHE STRING "Maximum concurrent connections")
set(STAT_CACHE_TTL        5      CACHE STRING "Stat cache TTL in seconds")
set(IO_BUFFER_SIZE        16384  CACHE STRING "I/O buffer size in bytes")

#-----------------------------------------------------------------------------
# Git Version Information
#-----------------------------------------------------------------------------
find_package(Git QUIET)
if(GIT_FOUND AND EXISTS "${CMAKE_SOURCE_DIR}/.git")
    execute_process(
        COMMAND ${GIT_EXECUTABLE} log -1 --format=%h
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    execute_process(
        COMMAND ${GIT_EXECUTABLE} log -1 --format=%ci
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT_DATE
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
else()
    set(GIT_COMMIT_HASH "unknown")
    set(GIT_COMMIT_DATE "unknown")
endif()

message(STATUS "Git commit: ${GIT_COMMIT_HASH}  (${GIT_COMMIT_DATE})")

#-----------------------------------------------------------------------------
# Generate config.h from config.h.in
# The generated header lands in the binary directory so it is never committed.
#-----------------------------------------------------------------------------
configure_file(
    "${CMAKE_SOURCE_DIR}/config.h.in"
    "${CMAKE_BINARY_DIR}/generated/config.h"
    @ONLY
)
# Make the generated directory a system include so all targets can find it.
include_directories(SYSTEM "${CMAKE_BINARY_DIR}/generated")
