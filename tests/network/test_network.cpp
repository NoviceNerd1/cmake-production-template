#include <gtest/gtest.h>
#include "myproject/network/server.h"

// ---------------------------------------------------------------------------
// Server construction / state tests
// ---------------------------------------------------------------------------
TEST(NetworkServerTest, ConstructorSetsPort) {
    myproject::Server s(9999);
    EXPECT_EQ(s.get_port(), 9999);
}

TEST(NetworkServerTest, InitiallyNotRunning) {
    myproject::Server s(9998);
    EXPECT_FALSE(s.is_running());
}

TEST(NetworkServerTest, StartSetsRunning) {
    myproject::Server s(9997);
    EXPECT_TRUE(s.start());
    EXPECT_TRUE(s.is_running());
    s.stop();
}

TEST(NetworkServerTest, StopClearsRunning) {
    myproject::Server s(9996);
    s.start();
    s.stop();
    EXPECT_FALSE(s.is_running());
}

TEST(NetworkServerTest, DoubleStartReturnsFalse) {
    myproject::Server s(9995);
    EXPECT_TRUE(s.start());
    EXPECT_FALSE(s.start());   // second start should fail / be idempotent
    s.stop();
}
