#include <gtest/gtest.h>
#include <fmt/core.h>

// ---------------------------------------------------------------------------
// Sanity / smoke tests
// ---------------------------------------------------------------------------
TEST(SmokeTest, TrueIsTrue) {
    EXPECT_TRUE(true);
}

TEST(SmokeTest, Arithmetic) {
    EXPECT_EQ(1 + 1, 2);
    EXPECT_NE(2 * 3, 7);
}

TEST(SmokeTest, FmtFormat) {
    std::string result = fmt::format("{} + {} = {}", 1, 2, 3);
    EXPECT_EQ(result, "1 + 2 = 3");
}

TEST(SmokeTest, StringOperations) {
    std::string s = "hello";
    EXPECT_EQ(s.size(), 5u);
    s += " world";
    EXPECT_EQ(s, "hello world");
}
