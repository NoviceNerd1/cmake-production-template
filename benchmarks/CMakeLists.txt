#=============================================================================
# benchmarks/CMakeLists.txt
# Google Benchmark micro-benchmarks
#=============================================================================
if(BUILD_BENCHMARKS)
    add_benchmark(benchmark_throughput
        SOURCES      benchmark_throughput.cpp
        DEPENDENCIES core network MyProject::benchmark_main
    )
endif()
