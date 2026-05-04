#include "myproject/core/version.h"
#include "myproject/network/server.h"
#include <fmt/core.h>
#include <spdlog/spdlog.h>
#include <iostream>

#include <atomic>
#include <csignal>
#include <thread>
#include <chrono>

static std::atomic<bool> g_keep_running{true};

void signal_handler(int signal) {
    if (signal == SIGINT || signal == SIGTERM) {
        g_keep_running = false;
    }
}

int main([[maybe_unused]] int argc, [[maybe_unused]] char* argv[]) {
    std::signal(SIGINT, signal_handler);
    std::signal(SIGTERM, signal_handler);

    spdlog::set_level(spdlog::level::info);
    spdlog::info("{} v{} starting", "MyProject", myproject::get_version());
    spdlog::info("Git commit: {}", myproject::GitHash);

    myproject::Server server(8080);

    if (server.start()) {
        spdlog::info("Server listening on port {}. Press Ctrl+C to stop.", server.get_port());
    } else {
        spdlog::error("Failed to start server");
        return 1;
    }

    // Main loop
    while (g_keep_running) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    spdlog::info("Shutdown signal received...");
    server.stop();
    spdlog::info("Server stopped. Goodbye.");
    
    return 0;
}
