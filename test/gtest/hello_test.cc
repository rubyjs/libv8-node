#include <gtest/gtest.h>

#include <v8.h>
#include <libplatform/libplatform.h>

// Demonstrate some basic assertions.
TEST(HelloTest, BasicAssertions) {
  std::shared_ptr<v8::Platform> platform = v8::platform::NewDefaultPlatform();

  // Expect two strings not to be equal.
  EXPECT_STRNE("hello", "world");
  // Expect equality.
  EXPECT_EQ(7 * 6, 42);
}
