#include "myproject/core/version.h"

namespace myproject {

const char* get_version() noexcept {
    return VersionString;
}

} // namespace myproject
