#pragma once
#include "config.h"

/// \file version.h
/// \brief Compile-time version constants for MyProject.
namespace myproject {

/// Major version number (changes on breaking API changes).
inline constexpr int VersionMajor = MyProject_VERSION_MAJOR;
/// Minor version number (new features, backwards compatible).
inline constexpr int VersionMinor = MyProject_VERSION_MINOR;
/// Patch version number (bug fixes only).
inline constexpr int VersionPatch = MyProject_VERSION_PATCH;

/// Full semver string, e.g. "1.0.0".
inline constexpr const char* VersionString = MyProject_VERSION;

/// Git commit hash at build time.
inline constexpr const char* GitHash = MyProject_GIT_COMMIT_HASH;

/// Returns the full version string (runtime accessor).
const char* get_version() noexcept;

} // namespace myproject
