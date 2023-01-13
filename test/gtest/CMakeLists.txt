cmake_minimum_required(VERSION 3.14)
project(gtest)

# GoogleTest requires at least C++14
set(CMAKE_CXX_STANDARD 14)

include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/03597a01ee50ed33e9dfd640b249b4be3799d395.zip
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

enable_testing()

include_directories(${CMAKE_SOURCE_DIR}/../../vendor/v8/include/)

add_executable(
  hello_test
  hello_test.cc
)
target_link_libraries(
  hello_test
  GTest::gtest_main
  ${CMAKE_SOURCE_DIR}/../../vendor/v8/x86_64-darwin/libv8/obj/libv8_monolith.a
)

include(GoogleTest)
gtest_discover_tests(hello_test)
