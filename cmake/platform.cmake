#=============================================================================
# Platform Detection and Configuration
# Sets PLATFORM_*, ARCH_*, HAVE_EPOLL, HAVE_KQUEUE, and configures ccache.
#=============================================================================

#-----------------------------------------------------------------------------
# Platform Identification
#-----------------------------------------------------------------------------
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(PLATFORM_LINUX TRUE)
    message(STATUS "Platform: Linux (${CMAKE_SYSTEM_PROCESSOR})")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(PLATFORM_MACOS TRUE)
    message(STATUS "Platform: macOS (${CMAKE_SYSTEM_PROCESSOR})")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(PLATFORM_WINDOWS TRUE)
    message(STATUS "Platform: Windows (${CMAKE_SYSTEM_PROCESSOR})")
else()
    message(WARNING "Unknown platform: ${CMAKE_SYSTEM_NAME}")
endif()

#-----------------------------------------------------------------------------
# CPU Architecture
#-----------------------------------------------------------------------------
if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|amd64|AMD64")
    set(ARCH_X86_64 TRUE)
    set(ARCH_NATIVE_FLAGS "-march=native")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64|ARM64")
    set(ARCH_AARCH64 TRUE)
    set(ARCH_NATIVE_FLAGS "-mcpu=native")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "armv7|armhf")
    set(ARCH_ARM32 TRUE)
    set(ARCH_NATIVE_FLAGS "-march=armv7-a -mfpu=neon")
endif()

message(STATUS "Architecture: ${CMAKE_SYSTEM_PROCESSOR}")

#-----------------------------------------------------------------------------
# Endianness
#-----------------------------------------------------------------------------
include(TestBigEndian)
test_big_endian(IS_BIG_ENDIAN)
if(IS_BIG_ENDIAN)
    message(STATUS "Endianness: Big Endian")
else()
    message(STATUS "Endianness: Little Endian")
endif()

#-----------------------------------------------------------------------------
# OS-Specific Settings
#-----------------------------------------------------------------------------
include(CheckCXXSourceCompiles)

if(PLATFORM_LINUX)
    add_compile_definitions(_GNU_SOURCE)
    find_package(Threads REQUIRED)
    set(PLATFORM_LIBRARIES Threads::Threads)

    check_cxx_source_compiles("
        #include <sys/epoll.h>
        int main() { int fd = epoll_create1(0); return fd >= 0 ? 0 : 1; }
    " HAVE_EPOLL)

    if(HAVE_EPOLL)
        add_compile_definitions(HAVE_EPOLL=1)
        message(STATUS "I/O backend: epoll")
    else()
        message(STATUS "I/O backend: select/poll (epoll not found)")
    endif()

elseif(PLATFORM_MACOS)
    add_compile_definitions(_DARWIN_USE_64_BIT_INODE)
    find_package(Threads REQUIRED)
    set(PLATFORM_LIBRARIES Threads::Threads)

    check_cxx_source_compiles("
        #include <sys/event.h>
        int main() { int kq = kqueue(); return kq >= 0 ? 0 : 1; }
    " HAVE_KQUEUE)

    if(HAVE_KQUEUE)
        add_compile_definitions(HAVE_KQUEUE=1)
        message(STATUS "I/O backend: kqueue")
    endif()

elseif(PLATFORM_WINDOWS)
    find_package(Threads REQUIRED)
    set(PLATFORM_LIBRARIES Threads::Threads)
    add_compile_definitions(_WIN32_WINNT=0x0A00)   # Windows 10+
endif()

#-----------------------------------------------------------------------------
# ccache — transparent compiler cache
#-----------------------------------------------------------------------------
if(ENABLE_CCACHE)
    find_program(CCACHE_PROGRAM ccache)
    if(CCACHE_PROGRAM)
        set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
        set(CMAKE_C_COMPILER_LAUNCHER   ${CCACHE_PROGRAM})
        # Sloppiness settings for better hit rate
        set(ENV{CCACHE_SLOPPINESS} "time_macros")
        set(ENV{CCACHE_HARDLINK}   "true")
        message(STATUS "ccache: ${CCACHE_PROGRAM}")
    else()
        message(STATUS "ccache: not found — builds will not be cached")
    endif()
endif()

#-----------------------------------------------------------------------------
# CPU Count (for build scripts / status messages)
#-----------------------------------------------------------------------------
include(ProcessorCount)
ProcessorCount(NPROC)
if(NPROC EQUAL 0)
    set(NPROC 4)
    message(STATUS "CPU cores: unknown — defaulting to ${NPROC}")
else()
    message(STATUS "CPU cores: ${NPROC}")
endif()

#-----------------------------------------------------------------------------
# Available RAM (Linux only, informational)
#-----------------------------------------------------------------------------
if(PLATFORM_LINUX)
    file(READ "/proc/meminfo" _MEMINFO)
    string(REGEX MATCH "MemTotal:[ \t]+([0-9]+)" _ "${_MEMINFO}")
    if(CMAKE_MATCH_1)
        math(EXPR MEMORY_GB "${CMAKE_MATCH_1} / 1024 / 1024")
        message(STATUS "System RAM: ${MEMORY_GB} GB")
    endif()
endif()
