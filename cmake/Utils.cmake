#=============================================================================
# Utils.cmake — Reusable Helper Functions
# Provides:
#   add_project_library()       — create a library with sane defaults
#   add_project_executable()    — create an executable with sane defaults
#   target_enable_unity_build() — opt-in unity build per target
#   target_enable_pch()         — precompiled headers per target
#   target_enable_sanitizers()  — apply active sanitizer flags per target
#   target_add_feature()        — add a compile-definition feature flag
#=============================================================================

#-----------------------------------------------------------------------------
# add_project_library(name [STATIC|SHARED|INTERFACE|OBJECT]
#                     SOURCES         src1.cpp ...
#                     PUBLIC_INCLUDES dir1 ...
#                     PRIVATE_INCLUDES dir1 ...
#                     DEPENDENCIES    lib1 ...)
#-----------------------------------------------------------------------------
function(add_project_library TARGET_NAME)
    cmake_parse_arguments(LIB
        "STATIC;SHARED;INTERFACE;OBJECT"    # type flags
        ""
        "SOURCES;PUBLIC_INCLUDES;PRIVATE_INCLUDES;DEPENDENCIES"
        ${ARGN}
    )

    # Determine library kind
    if(LIB_INTERFACE)
        add_library(${TARGET_NAME} INTERFACE)
    elseif(LIB_OBJECT)
        add_library(${TARGET_NAME} OBJECT ${LIB_SOURCES})
    elseif(LIB_SHARED OR BUILD_SHARED_LIBS)
        add_library(${TARGET_NAME} SHARED ${LIB_SOURCES})
    else()
        add_library(${TARGET_NAME} STATIC ${LIB_SOURCES})
    endif()

    # Include directories
    if(LIB_PUBLIC_INCLUDES)
        target_include_directories(${TARGET_NAME} PUBLIC ${LIB_PUBLIC_INCLUDES})
    endif()
    if(LIB_PRIVATE_INCLUDES)
        target_include_directories(${TARGET_NAME} PRIVATE ${LIB_PRIVATE_INCLUDES})
    endif()

    # Always make the generated header directory available
    target_include_directories(${TARGET_NAME} PUBLIC
        "${CMAKE_BINARY_DIR}/generated"
    )

    # Link libraries
    if(LIB_DEPENDENCIES)
        target_link_libraries(${TARGET_NAME} PUBLIC ${LIB_DEPENDENCIES})
    endif()

    # Enforce C++20
    if(NOT LIB_INTERFACE)
        target_compile_features(${TARGET_NAME} PUBLIC cxx_std_20)
    endif()

    # Namespace alias  (e.g. MyProject::core)
    add_library(${PROJECT_NAME}::${TARGET_NAME} ALIAS ${TARGET_NAME})

    message(STATUS "Library: ${TARGET_NAME}")
endfunction()

#-----------------------------------------------------------------------------
# add_project_executable(name
#                         SOURCES      src1.cpp ...
#                         DEPENDENCIES lib1 ...
#                         INCLUDES     dir1 ...)
#-----------------------------------------------------------------------------
function(add_project_executable TARGET_NAME)
    cmake_parse_arguments(EXE "" "" "SOURCES;DEPENDENCIES;INCLUDES" ${ARGN})

    add_executable(${TARGET_NAME} ${EXE_SOURCES})

    if(EXE_INCLUDES)
        target_include_directories(${TARGET_NAME} PRIVATE ${EXE_INCLUDES})
    endif()

    # Always make the generated header directory available
    target_include_directories(${TARGET_NAME} PRIVATE
        "${CMAKE_BINARY_DIR}/generated"
    )

    if(EXE_DEPENDENCIES)
        target_link_libraries(${TARGET_NAME} PRIVATE ${EXE_DEPENDENCIES})
    endif()

    target_compile_features(${TARGET_NAME} PRIVATE cxx_std_20)

    target_compile_definitions(${TARGET_NAME} PRIVATE
        PROJECT_VERSION="${PROJECT_VERSION}"
        PROJECT_NAME="${PROJECT_NAME}"
    )

    message(STATUS "Executable: ${TARGET_NAME}")
endfunction()

#-----------------------------------------------------------------------------
# target_enable_unity_build(target)
#   Activates CMake native unity build on the target.
#-----------------------------------------------------------------------------
function(target_enable_unity_build TARGET_NAME)
    if(ENABLE_UNITY_BUILD)
        set_target_properties(${TARGET_NAME} PROPERTIES
            UNITY_BUILD            ON
            UNITY_BUILD_BATCH_SIZE 32
        )
        message(STATUS "Unity build: ${TARGET_NAME}")
    endif()
endfunction()

#-----------------------------------------------------------------------------
# target_enable_pch(target pch_header)
#   Enables precompiled headers for a target.
#-----------------------------------------------------------------------------
function(target_enable_pch TARGET_NAME PCH_FILE)
    if(ENABLE_PRECOMPILED_HEADERS AND EXISTS "${PCH_FILE}")
        target_precompile_headers(${TARGET_NAME} PRIVATE "${PCH_FILE}")
        message(STATUS "PCH: ${TARGET_NAME} ← ${PCH_FILE}")
    endif()
endfunction()

#-----------------------------------------------------------------------------
# target_enable_sanitizers(target)
#   Applies whichever sanitizers are globally enabled to a specific target.
#   Useful when only certain targets need sanitizer instrumentation.
#-----------------------------------------------------------------------------
function(target_enable_sanitizers TARGET_NAME)
    if(ENABLE_ASAN)
        target_compile_options(${TARGET_NAME} PRIVATE -fsanitize=address)
        target_link_options(${TARGET_NAME}    PRIVATE -fsanitize=address)
    endif()
    if(ENABLE_UBSAN)
        target_compile_options(${TARGET_NAME} PRIVATE -fsanitize=undefined)
        target_link_options(${TARGET_NAME}    PRIVATE -fsanitize=undefined)
    endif()
    if(ENABLE_TSAN)
        target_compile_options(${TARGET_NAME} PRIVATE -fsanitize=thread)
        target_link_options(${TARGET_NAME}    PRIVATE -fsanitize=thread)
    endif()
endfunction()

#-----------------------------------------------------------------------------
# target_add_feature(target FEATURE_NAME)
#   Adds  MYPROJECT_HAVE_<FEATURE_NAME>=1  compile definition publicly.
#-----------------------------------------------------------------------------
function(target_add_feature TARGET_NAME FEATURE_NAME)
    if(FEATURE_NAME)
        target_compile_definitions(${TARGET_NAME} PUBLIC
            "${PROJECT_NAME}_HAVE_${FEATURE_NAME}=1"
        )
    endif()
endfunction()
