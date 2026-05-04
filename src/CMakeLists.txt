#=============================================================================
# src/CMakeLists.txt — Library and executable target definitions
#=============================================================================

# ---- Core library -------------------------------------------------------
add_project_library(core
    STATIC
    SOURCES
        core/src/version.cpp
    PUBLIC_INCLUDES
        core/include
)

# ---- Network library ----------------------------------------------------
add_project_library(network
    STATIC
    SOURCES
        network/src/server.cpp
    PUBLIC_INCLUDES
        network/include
    DEPENDENCIES
        core
        MyProject::spdlog
)

# ---- Main executable ----------------------------------------------------
add_project_executable(myapp
    SOURCES
        app/main.cpp
    DEPENDENCIES
        core
        network
        MyProject::fmt
        MyProject::spdlog
        ${PLATFORM_LIBRARIES}
)
