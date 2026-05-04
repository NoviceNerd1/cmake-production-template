#pragma once
#include <string>
#include <string_view>

/// \file types.h
/// \brief Common types used across MyProject modules.
namespace myproject {

/// Result type — carries either a value or an error message.
template <typename T>
struct Result {
    T           value{};
    std::string error{};
    bool        ok{true};

    static Result<T> success(T v)           { return {std::move(v), {}, true};  }
    static Result<T> failure(std::string e) { return {{},          std::move(e), false}; }

    explicit operator bool() const noexcept { return ok; }
};

/// Byte-level buffer view (non-owning).
using BufferView = std::string_view;

} // namespace myproject
