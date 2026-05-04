#=============================================================================
# examples/CMakeLists.txt
#=============================================================================
if(BUILD_EXAMPLES)
    add_project_executable(basic_server
        SOURCES
            basic_server/main.cpp
        DEPENDENCIES
            core
            network
            MyProject::fmt
            MyProject::spdlog
            ${PLATFORM_LIBRARIES}
    )
    message(STATUS "Example: basic_server")
endif()
