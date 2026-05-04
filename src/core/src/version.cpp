#include "myproject/core/version.h"

namespace myproject {

std::string_view get_version() noexcept {
    return VersionString;
}

} // namespace myproject
