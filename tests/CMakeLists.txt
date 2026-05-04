#=============================================================================
# tests/CMakeLists.txt — Unit test registration
# Uses add_gtest() from cmake/testing.cmake (included by root).
#=============================================================================

# Smoke / integration tests (no external deps needed)
add_gtest(test_smoke
    test_smoke.cpp
    TIMEOUT      30
    LABELS       "smoke"
)

# Core library tests
add_gtest(test_core
    core/test_core.cpp
    DEPENDENCIES core
    TIMEOUT      30
    LABELS       "unit;core"
)

# Network library tests
add_gtest(test_network
    network/test_network.cpp
    DEPENDENCIES network
    TIMEOUT      30
    LABELS       "unit;network"
)
