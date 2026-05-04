#include "core/version.h"
#include "network/server.h"
#include <fmt/core.h>
#include <spdlog/spdlog.h>
#include <iostream>

int main([[maybe_unused]] int argc, [[maybe_unused]] char* argv[]) {
    spdlog::set_level(spdlog::level::info);
    spdlog::info("{} v{} starting", "MyProject", myproject::get_version());
    spdlog::info("Git commit: {}", myproject::GitHash);

    myproject::Server server(8080);

    if (server.start()) {
        fmt::println("Server listening on port {}", server.get_port());
    } else {
        fmt::println(stderr, "ERROR: server failed to start");
        return 1;
    }

    fmt::println("Press Enter to stop...");
    std::cin.get();

    server.stop();
    fmt::println("Server stopped. Goodbye.");
    return 0;
}
