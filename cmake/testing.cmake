#=============================================================================
# Testing Configuration — GoogleTest + CTest integration
#=============================================================================

# Enable CTest (must be called before any add_test())
enable_testing()

#-----------------------------------------------------------------------------
# add_gtest()
#   Convenience wrapper to create a GTest-based test executable and register
#   it with CTest.
#
#   Usage:
#       add_gtest(test_name
#           source1.cpp [source2.cpp ...]
#           DEPENDENCIES lib1 lib2
#           TIMEOUT      30          # optional, seconds
#           LABELS       "unit"      # optional CTest labels
#       )
#-----------------------------------------------------------------------------
function(add_gtest TEST_NAME)
    cmake_parse_arguments(TEST
        ""                          # options (flags)
        "TIMEOUT;LABELS"            # one-value keywords
        "DEPENDENCIES"              # multi-value keywords
        ${ARGN}
    )

    # Remaining unparsed args are the source files
    set(TEST_SOURCES ${TEST_UNPARSED_ARGUMENTS})

    add_executable(${TEST_NAME} ${TEST_SOURCES})

    target_link_libraries(${TEST_NAME} PRIVATE
        MyProject::gtest_main
        ${TEST_DEPENDENCIES}
    )

    target_include_directories(${TEST_NAME} PRIVATE
        "${CMAKE_SOURCE_DIR}/tests"
        "${CMAKE_SOURCE_DIR}/include"
        "${CMAKE_BINARY_DIR}/generated"
    )

    target_compile_features(${TEST_NAME} PRIVATE cxx_std_20)

    # Register with CTest
    add_test(NAME ${TEST_NAME} COMMAND ${TEST_NAME})

    set(_props "")
    if(TEST_TIMEOUT)
        list(APPEND _props TIMEOUT ${TEST_TIMEOUT})
    endif()
    if(TEST_LABELS)
        list(APPEND _props LABELS "${TEST_LABELS}")
    endif()
    if(_props)
        set_tests_properties(${TEST_NAME} PROPERTIES ${_props})
    endif()

    # Hook coverage flags if requested
    if(ENABLE_COVERAGE)
        target_compile_options(${TEST_NAME} PRIVATE --coverage)
        target_link_options(${TEST_NAME}    PRIVATE --coverage)
    endif()

    message(STATUS "Test registered: ${TEST_NAME}")
endfunction()

#-----------------------------------------------------------------------------
# add_gtest_simple()
#   Thin alias for single-source tests.
#-----------------------------------------------------------------------------
function(add_gtest_simple TEST_NAME SOURCE_FILE)
    add_gtest(${TEST_NAME} ${SOURCE_FILE} ${ARGN})
endfunction()

#-----------------------------------------------------------------------------
# discover_tests()
#   Auto-discovers test files matching test_*.cpp inside a directory.
#-----------------------------------------------------------------------------
function(discover_tests DIRECTORY)
    file(GLOB_RECURSE _test_files "${DIRECTORY}/test_*.cpp")
    foreach(_file ${_test_files})
        get_filename_component(_name ${_file} NAME_WE)
        add_gtest(${_name} ${_file} ${ARGN})
    endforeach()
endfunction()

#-----------------------------------------------------------------------------
# add_benchmark()
#   Registers a Google Benchmark binary with CTest under the "benchmark" label.
#-----------------------------------------------------------------------------
function(add_benchmark BENCH_NAME)
    cmake_parse_arguments(BENCH "" "" "SOURCES;DEPENDENCIES" ${ARGN})
    if(BUILD_BENCHMARKS)
        add_executable(${BENCH_NAME} ${BENCH_SOURCES})
        target_link_libraries(${BENCH_NAME} PRIVATE
            MyProject::benchmark_main
            ${BENCH_DEPENDENCIES}
        )
        target_compile_features(${BENCH_NAME} PRIVATE cxx_std_20)
        add_test(NAME ${BENCH_NAME} COMMAND ${BENCH_NAME})
        set_tests_properties(${BENCH_NAME} PROPERTIES
            LABELS  "benchmark"
            TIMEOUT 300
        )
        message(STATUS "Benchmark registered: ${BENCH_NAME}")
    endif()
endfunction()

#-----------------------------------------------------------------------------
# Coverage report target (Linux + lcov)
#-----------------------------------------------------------------------------
if(ENABLE_COVERAGE AND PLATFORM_LINUX)
    find_program(LCOV_PATH    lcov)
    find_program(GENHTML_PATH genhtml)

    if(LCOV_PATH AND GENHTML_PATH)
        add_custom_target(coverage
            COMMAND ${LCOV_PATH} --capture --directory .
                    --output-file coverage.info --no-external
            COMMAND ${LCOV_PATH} --remove coverage.info
                    '/usr/*' '*/tests/*' '*/_deps/*'
                    --output-file coverage_filtered.info
            COMMAND ${GENHTML_PATH} coverage_filtered.info
                    --output-directory coverage_report
            COMMAND ${CMAKE_COMMAND} -E echo
                    "Report: ${CMAKE_BINARY_DIR}/coverage_report/index.html"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Generating code coverage report (lcov)"
        )
        message(STATUS "Coverage target 'coverage' available")
    else()
        message(WARNING "lcov/genhtml not found — 'coverage' target disabled")
    endif()
endif()
