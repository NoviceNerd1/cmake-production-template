#=============================================================================
# Utils.cmake — Reusable Helper Functions
# Provides:
#   add_project_library()       — create a library with sane defaults
#   add_project_executable()    — create an executable with sane defaults
#   target_enable_unity_build() — opt-in unity build per target
#   target_enable_pch()         — precompiled headers per target
#   target_enable_sanitizers()  — apply active sanitizer flags per target (extra)
#=============================================================================

#-----------------------------------------------------------------------------
# add_project_library()
#-----------------------------------------------------------------------------
function(add_project_library TARGET_NAME)
    cmake_parse_arguments(LIB
        "STATIC;SHARED;INTERFACE;OBJECT"
        ""
        "SOURCES;PUBLIC_INCLUDES;PRIVATE_INCLUDES;DEPENDENCIES"
        ${ARGN}
    )

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
        foreach(_dir ${LIB_PUBLIC_INCLUDES})
            target_include_directories(${TARGET_NAME} PUBLIC
                "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${_dir}>"
                "$<INSTALL_INTERFACE:include>"
            )
        endforeach()
    endif()

    target_include_directories(${TARGET_NAME} PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/generated>"
    )

    if(LIB_DEPENDENCIES)
        target_link_libraries(${TARGET_NAME} PUBLIC ${LIB_DEPENDENCIES})
    endif()

    # Apply Production standards
    if(NOT LIB_INTERFACE)
        target_compile_features(${TARGET_NAME} PUBLIC cxx_std_20)
        target_compile_options(${TARGET_NAME} PRIVATE ${PROJECT_WARNING_FLAGS})
    endif()

    add_library(${PROJECT_NAME}::${TARGET_NAME} ALIAS ${TARGET_NAME})
    message(STATUS "Library: ${TARGET_NAME}")
endfunction()

#-----------------------------------------------------------------------------
# add_project_executable()
#-----------------------------------------------------------------------------
function(add_project_executable TARGET_NAME)
    cmake_parse_arguments(EXE "" "" "SOURCES;DEPENDENCIES;INCLUDES" ${ARGN})

    add_executable(${TARGET_NAME} ${EXE_SOURCES})

    target_include_directories(${TARGET_NAME} PRIVATE
        "$<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/generated>"
    )

    if(EXE_DEPENDENCIES)
        target_link_libraries(${TARGET_NAME} PRIVATE ${EXE_DEPENDENCIES})
    endif()

    target_compile_features(${TARGET_NAME} PRIVATE cxx_std_20)
    target_compile_options(${TARGET_NAME}  PRIVATE ${PROJECT_WARNING_FLAGS})

    message(STATUS "Executable: ${TARGET_NAME}")
endfunction()

#-----------------------------------------------------------------------------
# target_enable_unity_build(target)
#-----------------------------------------------------------------------------
function(target_enable_unity_build TARGET_NAME)
    if(ENABLE_UNITY_BUILD)
        set_target_properties(${TARGET_NAME} PROPERTIES
            UNITY_BUILD            ON
            UNITY_BUILD_BATCH_SIZE 32
        )
        message(STATUS "Unity build enabled: ${TARGET_NAME}")
    endif()
endfunction()

#-----------------------------------------------------------------------------
# target_enable_pch(target pch_header)
#-----------------------------------------------------------------------------
function(target_enable_pch TARGET_NAME PCH_FILE)
    if(ENABLE_PRECOMPILED_HEADERS AND EXISTS "${PCH_FILE}")
        target_precompile_headers(${TARGET_NAME} PRIVATE "${PCH_FILE}")
        message(STATUS "PCH enabled: ${TARGET_NAME}")
    endif()
endfunction()
