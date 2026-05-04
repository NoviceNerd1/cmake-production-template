#=============================================================================
# CMake Template - Production-Ready Build System
# Target: Modern C++20 projects
# Requires: CMake 3.20+, Ninja, GCC 11+ / Clang 15+ / MSVC 2022
#=============================================================================
cmake_minimum_required(VERSION 3.20)

#-----------------------------------------------------------------------------
# Project Declaration
#-----------------------------------------------------------------------------
project(MyProject
    VERSION 1.0.0
    DESCRIPTION "Production C++ project template"
    LANGUAGES CXX
)

#-----------------------------------------------------------------------------
# Options (User-configurable features)
# Loaded first — everything else depends on option values.
#-----------------------------------------------------------------------------
include(cmake/options.cmake)

#-----------------------------------------------------------------------------
# Compiler Configuration (Warnings, Sanitizers, LTO)
#-----------------------------------------------------------------------------
include(cmake/compiler.cmake)

#-----------------------------------------------------------------------------
# Platform Detection & Toolchain
#-----------------------------------------------------------------------------
include(cmake/platform.cmake)

#-----------------------------------------------------------------------------
# External Dependencies (fmt, spdlog, GoogleTest, etc.)
#-----------------------------------------------------------------------------
include(cmake/dependencies.cmake)

#-----------------------------------------------------------------------------
# Helper Macros — must come before any add_subdirectory() calls
#-----------------------------------------------------------------------------
include(cmake/Utils.cmake)

#-----------------------------------------------------------------------------
# Main Sources: Libraries & Executables
#-----------------------------------------------------------------------------
add_subdirectory(src)

#-----------------------------------------------------------------------------
# Unit Tests (Conditional)
#-----------------------------------------------------------------------------
if(BUILD_TESTING)
    include(cmake/testing.cmake)
    add_subdirectory(tests)
endif()

#-----------------------------------------------------------------------------
# Benchmarks (Conditional)
#-----------------------------------------------------------------------------
if(BUILD_BENCHMARKS)
    add_subdirectory(benchmarks)
endif()

#-----------------------------------------------------------------------------
# Examples (Conditional)
#-----------------------------------------------------------------------------
if(BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

#-----------------------------------------------------------------------------
# Documentation (Doxygen)
#-----------------------------------------------------------------------------
if(BUILD_DOCS)
    find_package(Doxygen QUIET)
    if(DOXYGEN_FOUND)
        configure_file(
            "${CMAKE_SOURCE_DIR}/docs/Doxyfile.in"
            "${CMAKE_BINARY_DIR}/Doxyfile"
            @ONLY
        )
        add_custom_target(docs
            COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/Doxyfile
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Generating API documentation with Doxygen"
            VERBATIM
        )
        message(STATUS "Doxygen documentation enabled")
    else()
        message(WARNING "Doxygen not found — BUILD_DOCS=ON has no effect")
    endif()
endif()

#-----------------------------------------------------------------------------
# Installation & Packaging
#-----------------------------------------------------------------------------
include(cmake/install.cmake)
include(cmake/packaging.cmake)

#-----------------------------------------------------------------------------
# Build Summary
#-----------------------------------------------------------------------------
message(STATUS "================================================================================")
message(STATUS "Project  : ${PROJECT_NAME} ${PROJECT_VERSION}")
message(STATUS "Build    : ${CMAKE_BUILD_TYPE}")
message(STATUS "C++      : ${CMAKE_CXX_STANDARD}")
message(STATUS "Compiler : ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "Tests    : ${BUILD_TESTING}")
message(STATUS "Benches  : ${BUILD_BENCHMARKS}")
message(STATUS "Examples : ${BUILD_EXAMPLES}")
message(STATUS "Prefix   : ${CMAKE_INSTALL_PREFIX}")
message(STATUS "================================================================================")
