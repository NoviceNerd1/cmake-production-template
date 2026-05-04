#=============================================================================
# CPack Packaging Configuration
# Run:  cpack --config build/release/CPackConfig.cmake  -B build/release/packages
#=============================================================================

set(CPACK_PACKAGE_NAME                "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION             "${PROJECT_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
set(CPACK_PACKAGE_VENDOR              "Your Organization")
set(CPACK_PACKAGE_CONTACT             "admin@example.com")
set(CPACK_PACKAGE_HOMEPAGE_URL        "https://github.com/yourname/myproject")
set(CPACK_RESOURCE_FILE_LICENSE       "${CMAKE_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README        "${CMAKE_SOURCE_DIR}/README.md")

#-----------------------------------------------------------------------------
# Output location
#-----------------------------------------------------------------------------
set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_BINARY_DIR}/packages")

#-----------------------------------------------------------------------------
# Select generators
#-----------------------------------------------------------------------------
set(CPACK_GENERATOR "")

if(PACKAGE_TGZ)
    list(APPEND CPACK_GENERATOR "TGZ")
endif()

if(PACKAGE_DEB AND PLATFORM_LINUX)
    list(APPEND CPACK_GENERATOR "DEB")
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS      "libc6, libstdc++6")
    set(CPACK_DEBIAN_PACKAGE_SECTION      "devel")
endif()

if(PACKAGE_RPM AND PLATFORM_LINUX)
    list(APPEND CPACK_GENERATOR "RPM")
    set(CPACK_RPM_PACKAGE_REQUIRES "glibc, libstdc++")
    set(CPACK_RPM_PACKAGE_GROUP    "Development/Libraries")
endif()

if(PACKAGE_NSIS AND PLATFORM_WINDOWS)
    list(APPEND CPACK_GENERATOR "NSIS")
endif()

if(NOT CPACK_GENERATOR)
    set(CPACK_GENERATOR "TGZ")   # sensible default
endif()

#-----------------------------------------------------------------------------
# Component-based packaging
#-----------------------------------------------------------------------------
set(CPACK_COMPONENTS_ALL libraries headers runtime)
if(BUILD_TESTING)
    list(APPEND CPACK_COMPONENTS_ALL tests)
endif()

include(CPack)

message(STATUS "CPack generators: ${CPACK_GENERATOR}")
