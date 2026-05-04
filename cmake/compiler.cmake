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
# Warning Definitions (Target-level)
#-----------------------------------------------------------------------------
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|AppleClang")
    set(PROJECT_WARNING_FLAGS
        -Wall -Wextra -Wpedantic
        -Wshadow -Wnon-virtual-dtor
        -Wold-style-cast -Wcast-align
        -Wunused -Woverloaded-virtual
        -Wformat=2 -Wdouble-promotion
        -Wnull-dereference
    )
    if(ENABLE_WARNINGS_AS_ERRORS)
        list(APPEND PROJECT_WARNING_FLAGS -Werror)
    endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(PROJECT_WARNING_FLAGS /W4 /permissive- /w14640)
    if(ENABLE_WARNINGS_AS_ERRORS)
        list(APPEND PROJECT_WARNING_FLAGS /WX)
    endif()
endif()

#-----------------------------------------------------------------------------
# Global Optimization & Debug Flags
#-----------------------------------------------------------------------------
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|AppleClang")
    set(CMAKE_CXX_FLAGS_DEBUG          "-O0 -g3 -DDEBUG -fno-omit-frame-pointer")
    set(CMAKE_CXX_FLAGS_RELEASE        "-O3 -DNDEBUG")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG")
    
    # Split DWARF (faster debug linking)
    if(CMAKE_BUILD_TYPE MATCHES "Debug|RelWithDebInfo" AND NOT CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
        add_compile_options(-gsplit-dwarf)
    endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS_DEBUG          "/Od /Zi /DDEBUG")
    set(CMAKE_CXX_FLAGS_RELEASE        "/O2 /DNDEBUG")
endif()

#-----------------------------------------------------------------------------
# LTO (Global)
#-----------------------------------------------------------------------------
if(ENABLE_LTO OR ENABLE_IPO)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT ipo_supported OUTPUT ipo_error)
    if(ipo_supported)
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
        message(STATUS "LTO/IPO enabled globally")
    else()
        message(WARNING "LTO/IPO requested but not supported: ${ipo_error}")
    endif()
endif()

#-----------------------------------------------------------------------------
# Sanitizers (Global)
#-----------------------------------------------------------------------------
if(ENABLE_ASAN OR ENABLE_UBSAN OR ENABLE_TSAN)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|AppleClang")
        if(ENABLE_ASAN)
            add_compile_options(-fsanitize=address -fno-omit-frame-pointer)
            add_link_options(-fsanitize=address)
        endif()
        if(ENABLE_UBSAN)
            add_compile_options(-fsanitize=undefined)
            add_link_options(-fsanitize=undefined)
        endif()
        if(ENABLE_TSAN)
            add_compile_options(-fsanitize=thread)
            add_link_options(-fsanitize=thread)
        endif()
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND ENABLE_ASAN)
        add_compile_options(/fsanitize=address)
    endif()
endif()

#-----------------------------------------------------------------------------
# Coverage (Global)
#-----------------------------------------------------------------------------
if(ENABLE_COVERAGE)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|AppleClang")
        add_compile_options(--coverage -O0 -g)
        add_link_options(--coverage)
    endif()
endif()

#-----------------------------------------------------------------------------
# Feature Checks (generated/features.h)
#-----------------------------------------------------------------------------
include(CheckCXXSourceCompiles)
check_cxx_source_compiles("thread_local int x = 42; int main() { return x; }" HAVE_THREAD_LOCAL)
check_cxx_source_compiles("#include <cmath>\nint main() { constexpr double pi = 3.14159; return static_cast<int>(pi); }" HAVE_CONSTEXPR_CMATH)

configure_file("${CMAKE_SOURCE_DIR}/cmake/features.h.in" "${CMAKE_BINARY_DIR}/generated/features.h" @ONLY)

message(STATUS "Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
