#include <gtest/gtest.h>
#include <string>

// ---------------------------------------------------------------------------
// Sanity / smoke tests — verify the test harness itself works
// No external library dependencies beyond GoogleTest.
// ---------------------------------------------------------------------------
TEST(SmokeTest, TrueIsTrue) {
    EXPECT_TRUE(true);
}

TEST(SmokeTest, Arithmetic) {
    EXPECT_EQ(1 + 1, 2);
    EXPECT_NE(2 * 3, 7);
    EXPECT_GE(10, 5);
}

TEST(SmokeTest, StringOperations) {
    std::string s = "hello";
    EXPECT_EQ(s.size(), 5u);
    s += " world";
    EXPECT_EQ(s, "hello world");
}

TEST(SmokeTest, VectorPushBack) {
    std::vector<int> v;
    v.push_back(1);
    v.push_back(2);
    v.push_back(3);
    EXPECT_EQ(v.size(), 3u);
    EXPECT_EQ(v[0], 1);
}
