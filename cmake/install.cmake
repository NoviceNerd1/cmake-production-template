#=============================================================================
# Installation Rules --- GNU standard directories
# Installs: binaries, libraries, headers, CMake config, docs, and license.
#=============================================================================
include(GNUInstallDirs)

#-----------------------------------------------------------------------------
# Targets
#-----------------------------------------------------------------------------
install(TARGETS myapp core network
    EXPORT  MyProjectTargets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}          # executables
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}          # shared libs
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}          # static libs
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

#-----------------------------------------------------------------------------
# Public Headers
#-----------------------------------------------------------------------------
install(DIRECTORY src/core/include/myproject/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/myproject
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
)

install(DIRECTORY src/network/include/myproject/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/myproject
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
)

# Generated config header
install(FILES "${CMAKE_BINARY_DIR}/generated/config.h"
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/myproject
)

#-----------------------------------------------------------------------------
# Documentation & License
#-----------------------------------------------------------------------------
if(EXISTS "${CMAKE_SOURCE_DIR}/README.md")
    install(FILES README.md DESTINATION ${CMAKE_INSTALL_DOCDIR})
endif()

if(EXISTS "${CMAKE_SOURCE_DIR}/LICENSE")
    install(FILES LICENSE DESTINATION ${CMAKE_INSTALL_DOCDIR})
endif()

#-----------------------------------------------------------------------------
# CMake Package Config Files
# Consuming projects can do: find_package(MyProject REQUIRED)
#-----------------------------------------------------------------------------
include(CMakePackageConfigHelpers)

configure_package_config_file(
    "${CMAKE_SOURCE_DIR}/cmake/MyProjectConfig.cmake.in"
    "${CMAKE_BINARY_DIR}/MyProjectConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyProject
)

write_basic_package_version_file(
    "${CMAKE_BINARY_DIR}/MyProjectConfigVersion.cmake"
    VERSION            ${PROJECT_VERSION}
    COMPATIBILITY      SameMajorVersion
)

install(FILES
    "${CMAKE_BINARY_DIR}/MyProjectConfig.cmake"
    "${CMAKE_BINARY_DIR}/MyProjectConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyProject
)

install(EXPORT MyProjectTargets
    FILE        MyProjectTargets.cmake
    NAMESPACE   MyProject::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyProject
)

message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")
