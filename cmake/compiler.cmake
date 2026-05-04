#=============================================================================
# Compiler Detection and Configuration
# Sets C++ standard, warnings, build-type flags, sanitizers, LTO, and coverage.
#=============================================================================

#-----------------------------------------------------------------------------
# C++ Standard
#-----------------------------------------------------------------------------
set(CMAKE_CXX_STANDARD          20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS        OFF)

#-----------------------------------------------------------------------------
# GCC / Clang / AppleClang
#-----------------------------------------------------------------------------
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|AppleClang")

    # --- Warnings ---------------------------------------------------------
    add_compile_options(
        -Wall -Wextra -Wpedantic
        -Wshadow -Wconversion -Wsign-conversion
        -Wnon-virtual-dtor
    )

    # --- Per-config flags -------------------------------------------------
    set(CMAKE_CXX_FLAGS_DEBUG          "-O0 -g3 -DDEBUG -fno-omit-frame-pointer")
    set(CMAKE_CXX_FLAGS_RELEASE        "-O3 -DNDEBUG")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG")
    set(CMAKE_CXX_FLAGS_MINSIZEREL     "-Os -DNDEBUG")

    # --- Split DWARF (faster debug linking) --------------------------------
    if(CMAKE_BUILD_TYPE MATCHES "Debug|RelWithDebInfo")
        if(NOT CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
            add_compile_options(-gsplit-dwarf)
        endif()
    endif()

    # --- LTO ---------------------------------------------------------------
    if(ENABLE_LTO OR ENABLE_IPO)
        if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|AppleClang")
            add_compile_options(-flto=thin)
            add_link_options(-flto=thin)
        else()
            add_compile_options(-flto=auto)
            add_link_options(-flto=auto)
        endif()
        message(STATUS "LTO enabled (${CMAKE_CXX_COMPILER_ID})")
    endif()

    # --- Sanitizers --------------------------------------------------------
    if(ENABLE_ASAN)
        add_compile_options(-fsanitize=address -fno-omit-frame-pointer)
        add_link_options(-fsanitize=address)
        if(ENABLE_UBSAN)
            add_compile_options(-fsanitize=undefined)
            add_link_options(-fsanitize=undefined)
            message(STATUS "ASAN + UBSAN enabled")
        else()
            message(STATUS "ASAN enabled")
        endif()
    elseif(ENABLE_UBSAN)
        add_compile_options(-fsanitize=undefined)
        add_link_options(-fsanitize=undefined)
        message(STATUS "UBSAN enabled")
    endif()

    if(ENABLE_TSAN)
        if(ENABLE_ASAN OR ENABLE_UBSAN)
            message(FATAL_ERROR "TSAN cannot be combined with ASAN or UBSAN")
        endif()
        add_compile_options(-fsanitize=thread)
        add_link_options(-fsanitize=thread)
        message(STATUS "TSAN enabled")
    endif()

    # --- Coverage ----------------------------------------------------------
    if(ENABLE_COVERAGE)
        add_compile_options(--coverage -O0 -g)
        add_link_options(--coverage)
        message(STATUS "Coverage instrumentation enabled")
    endif()

    # --- Warnings-as-errors ------------------------------------------------
    if(ENABLE_WARNINGS_AS_ERRORS)
        add_compile_options(-Werror)
        message(STATUS "Warnings treated as errors (-Werror)")
    endif()

#-----------------------------------------------------------------------------
# MSVC
#-----------------------------------------------------------------------------
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    add_compile_options(/W4 /WX- /permissive-)

    set(CMAKE_CXX_FLAGS_DEBUG          "/Od /Zi /DDEBUG")
    set(CMAKE_CXX_FLAGS_RELEASE        "/O2 /DNDEBUG")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "/O2 /Zi /DNDEBUG")

    if(ENABLE_LTO OR ENABLE_IPO)
        add_compile_options(/GL)
        add_link_options(/LTCG)
        message(STATUS "LTCG (LTO) enabled for MSVC")
    endif()

    if(ENABLE_ASAN)
        add_compile_options(/fsanitize=address)
        message(STATUS "ASAN enabled (MSVC)")
    endif()

    if(ENABLE_WARNINGS_AS_ERRORS)
        add_compile_options(/WX)
        message(STATUS "Warnings treated as errors (/WX)")
    endif()

else()
    message(WARNING "Unknown compiler '${CMAKE_CXX_COMPILER_ID}' — no flags applied")
endif()

#-----------------------------------------------------------------------------
# Feature Checks  (results used in features.h)
#-----------------------------------------------------------------------------
include(CheckCXXSourceCompiles)

check_cxx_source_compiles("
    thread_local int x = 42;
    int main() { return x; }
" HAVE_THREAD_LOCAL)

check_cxx_source_compiles("
    #include <cmath>
    int main() {
        constexpr double pi = 3.14159;
        return static_cast<int>(pi);
    }
" HAVE_CONSTEXPR_CMATH)

# Generate features header
configure_file(
    "${CMAKE_SOURCE_DIR}/cmake/features.h.in"
    "${CMAKE_BINARY_DIR}/generated/features.h"
    @ONLY
)

message(STATUS "Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
