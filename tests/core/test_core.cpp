#include <gtest/gtest.h>
#include "core/version.h"
#include "core/types.h"

// ---------------------------------------------------------------------------
// Version tests
// ---------------------------------------------------------------------------
TEST(CoreVersionTest, MajorIsPositive) {
    EXPECT_GE(myproject::VersionMajor, 1);
}

TEST(CoreVersionTest, VersionStringNotEmpty) {
    EXPECT_NE(myproject::VersionString, nullptr);
    EXPECT_GT(std::string(myproject::VersionString).size(), 0u);
}

TEST(CoreVersionTest, GetVersionMatchesConstant) {
    EXPECT_STREQ(myproject::get_version(), myproject::VersionString);
}

// ---------------------------------------------------------------------------
// Types tests
// ---------------------------------------------------------------------------
TEST(CoreTypesTest, ResultSuccess) {
    auto r = myproject::Result<int>::success(42);
    EXPECT_TRUE(r.ok);
    EXPECT_EQ(r.value, 42);
    EXPECT_TRUE(r.error.empty());
    EXPECT_TRUE(static_cast<bool>(r));
}

TEST(CoreTypesTest, ResultFailure) {
    auto r = myproject::Result<int>::failure("something went wrong");
    EXPECT_FALSE(r.ok);
    EXPECT_EQ(r.error, "something went wrong");
    EXPECT_FALSE(static_cast<bool>(r));
}

TEST(CoreTypesTest, BufferView) {
    std::string  data  = "hello";
    myproject::BufferView view = data;
    EXPECT_EQ(view.size(), 5u);
    EXPECT_EQ(view[0], 'h');
}
