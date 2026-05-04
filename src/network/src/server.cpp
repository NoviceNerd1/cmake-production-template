#include "network/server.h"
#include <spdlog/spdlog.h>

#if defined(HAVE_EPOLL)
  #include <sys/epoll.h>
  #include <unistd.h>
#elif defined(HAVE_KQUEUE)
  #include <sys/event.h>
  #include <unistd.h>
#endif

namespace myproject {

Server::Server(int port)
    : port_(port), listen_fd_(-1), running_(false)
{
    spdlog::info("Server: created on port {}", port_);
}

Server::~Server() {
    stop();
}

bool Server::start() {
    if (running_) {
        spdlog::warn("Server: already running on port {}", port_);
        return false;
    }
    spdlog::info("Server: starting on port {}", port_);
    running_ = true;
    // Actual socket setup would go here in a real server.
    return true;
}

void Server::stop() {
    if (!running_) return;
    spdlog::info("Server: stopping (port {})", port_);
    running_ = false;
    if (listen_fd_ >= 0) {
#if defined(HAVE_EPOLL) || defined(HAVE_KQUEUE)
        ::close(listen_fd_);
#endif
        listen_fd_ = -1;
    }
}

} // namespace myproject
