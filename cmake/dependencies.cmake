#=============================================================================
# External Dependency Management
# Strategy: prefer system libraries, fall back to FetchContent.
# All deps are aliased under the MyProject:: namespace.
#=============================================================================
include(FetchContent)

#-----------------------------------------------------------------------------
# Helper: set FetchContent to use shallow clones for speed
#-----------------------------------------------------------------------------
set(FETCHCONTENT_QUIET ON)

#=============================================================================
# Threads  (always required)
#=============================================================================
find_package(Threads REQUIRED)
add_library(MyProject::Threads ALIAS Threads::Threads)

#=============================================================================
# fmt --- string formatting library
#=============================================================================
macro(find_or_fetch_fmt)
    find_package(fmt CONFIG QUIET)
    if(fmt_FOUND)
        message(STATUS "fmt: ${fmt_VERSION} (system)")
        add_library(MyProject::fmt ALIAS fmt::fmt)
    else()
        message(STATUS "fmt: not found --- fetching v10.2.1 from GitHub")
        FetchContent_Declare(
            fmt
            GIT_REPOSITORY https://github.com/fmtlib/fmt.git
            GIT_TAG        10.2.1
            GIT_SHALLOW    TRUE
        )
        FetchContent_MakeAvailable(fmt)
        add_library(MyProject::fmt ALIAS fmt)
    endif()
endmacro()

#=============================================================================
# spdlog --- fast logging library  (uses fmt internally)
#=============================================================================
macro(find_or_fetch_spdlog)
    find_package(spdlog CONFIG QUIET)
    if(spdlog_FOUND)
        message(STATUS "spdlog: ${spdlog_VERSION} (system)")
        add_library(MyProject::spdlog ALIAS spdlog::spdlog)
    else()
        message(STATUS "spdlog: not found --- fetching v1.14.1 from GitHub")
        FetchContent_Declare(
            spdlog
            GIT_REPOSITORY https://github.com/gabime/spdlog.git
            GIT_TAG        v1.14.1
            GIT_SHALLOW    TRUE
        )
        FetchContent_MakeAvailable(spdlog)
        add_library(MyProject::spdlog ALIAS spdlog)
    endif()
endmacro()

#=============================================================================
# GoogleTest --- unit testing framework (only when BUILD_TESTING)
# We always fetch GTest from source to guarantee static linking and avoid
# rpath / ABI issues with system-installed dylibs (e.g. conda on macOS).
#=============================================================================
macro(find_or_fetch_gtest)
    if(BUILD_TESTING)
        message(STATUS "GTest: fetching v1.14.0 from GitHub (always built from source)")
        set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
        set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)   # MSVC compat
        FetchContent_Declare(
            googletest
            GIT_REPOSITORY https://github.com/google/googletest.git
            GIT_TAG        v1.14.0
            GIT_SHALLOW    TRUE
        )
        FetchContent_MakeAvailable(googletest)
        add_library(MyProject::gtest      ALIAS gtest)
        add_library(MyProject::gtest_main ALIAS gtest_main)
    endif()
endmacro()

#=============================================================================
# Google Benchmark --- performance micro-benchmarks (only when BUILD_BENCHMARKS)
#=============================================================================
macro(find_or_fetch_benchmark)
    if(BUILD_BENCHMARKS)
        find_package(benchmark CONFIG QUIET)
        if(benchmark_FOUND)
            message(STATUS "benchmark: ${benchmark_VERSION} (system)")
            add_library(MyProject::benchmark      ALIAS benchmark::benchmark)
            add_library(MyProject::benchmark_main ALIAS benchmark::benchmark_main)
        else()
            message(STATUS "benchmark: not found --- fetching v1.8.3 from GitHub")
            set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
            FetchContent_Declare(
                googlebenchmark
                GIT_REPOSITORY https://github.com/google/benchmark.git
                GIT_TAG        v1.8.3
                GIT_SHALLOW    TRUE
            )
            FetchContent_MakeAvailable(googlebenchmark)
            add_library(MyProject::benchmark      ALIAS benchmark)
            add_library(MyProject::benchmark_main ALIAS benchmark_main)
        endif()
    endif()
endmacro()

#=============================================================================
# OpenSSL --- cryptography (optional)
#=============================================================================
macro(find_or_fetch_openssl)
    find_package(OpenSSL QUIET)
    if(OpenSSL_FOUND)
        message(STATUS "OpenSSL: ${OpenSSL_VERSION} (system)")
        add_library(MyProject::ssl    ALIAS OpenSSL::SSL)
        add_library(MyProject::crypto ALIAS OpenSSL::Crypto)
        set(MyProject_HAVE_SSL TRUE)
    else()
        message(STATUS "OpenSSL: not found --- SSL support disabled")
        set(MyProject_HAVE_SSL FALSE)
    endif()
endmacro()

#=============================================================================
# zlib --- compression (optional)
#=============================================================================
macro(find_or_fetch_zlib)
    find_package(ZLIB QUIET)
    if(ZLIB_FOUND)
        message(STATUS "ZLIB: ${ZLIB_VERSION_STRING} (system)")
        add_library(MyProject::zlib ALIAS ZLIB::ZLIB)
        set(MyProject_HAVE_ZLIB TRUE)
    else()
        message(STATUS "ZLIB: not found --- compression disabled")
        set(MyProject_HAVE_ZLIB FALSE)
    endif()
endmacro()

#=============================================================================
# Activate all dependency macros
#=============================================================================
find_or_fetch_fmt()
find_or_fetch_spdlog()
find_or_fetch_gtest()
find_or_fetch_benchmark()
find_or_fetch_openssl()
find_or_fetch_zlib()

# Propagate SSL/ZLIB availability to config.h
set(MyProject_ENABLE_SSL  ${MyProject_HAVE_SSL})
set(MyProject_ENABLE_ZLIB ${MyProject_HAVE_ZLIB})
