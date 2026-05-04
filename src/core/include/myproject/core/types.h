#pragma once
#include <string>
#include <string_view>

/// \file types.h
/// \brief Common types used across MyProject modules.
namespace myproject {

/// Result type — carries either a value or an error message.
template <typename T>
class Result {
public:
    Result() : ok_(false), error_("uninitialized") {}
    
    static Result<T> success(T v) {
        Result res;
        res.value_ = std::move(v);
        res.ok_ = true;
        res.error_.clear();
        return res;
    }

    static Result<T> failure(std::string e) {
        Result res;
        res.ok_ = false;
        res.error_ = std::move(e);
        return res;
    }

    [[nodiscard]] bool has_value() const noexcept { return ok_; }
    [[nodiscard]] bool ok()        const noexcept { return ok_; }
    
    const T& value() const { return value_; }
    const std::string& error() const noexcept { return error_; }

    explicit operator bool() const noexcept { return ok_; }

private:
    T           value_{};
    std::string error_{};
    bool        ok_{false};
};

/// Byte-level buffer view (non-owning).
using BufferView = std::string_view;

} // namespace myproject
