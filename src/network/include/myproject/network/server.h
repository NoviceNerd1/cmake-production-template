#pragma once
#include <myproject/core/types.h>
#include <string>

/// \file server.h
/// \brief Minimal TCP server abstraction for the network library.
namespace myproject {

/// A simple TCP listening server.
class Server {
public:
    /// Construct a server that will listen on \p port.
    explicit Server(uint16_t port);
    ~Server();

    // Non-copyable, non-movable (owns OS resources)
    Server(const Server&)            = delete;
    Server& operator=(const Server&) = delete;
    Server(Server&&)                 = delete;
    Server& operator=(Server&&)      = delete;

    /// Start listening.  Returns true on success.
    [[nodiscard]] bool start();

    /// Gracefully stop the server.
    void stop();

    /// Returns the port number this server is listening on.
    [[nodiscard]] uint16_t get_port()    const noexcept { return port_;    }
    /// Returns true if the server is currently running.
    [[nodiscard]] bool     is_running()  const noexcept { return running_; }

private:
    uint16_t port_;
    int      listen_fd_;
    bool     running_;
};

} // namespace myproject
