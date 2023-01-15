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
  c_v8_tests
  c_v8_tests.cc
)
target_link_libraries(
  c_v8_tests
  GTest::gtest_main
)

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  target_link_libraries(c_v8_tests ${CMAKE_SOURCE_DIR}/../../vendor/v8/x86_64-darwin/libv8/obj/libv8_monolith.a)
else()
  target_link_libraries(c_v8_tests ${CMAKE_SOURCE_DIR}/../../vendor/v8/x86_64-linux/libv8/obj/libv8_monolith.a)
endif()

# This has to be after the v8 monolith for some build setups.
target_link_libraries(c_v8_tests dl)

include(GoogleTest)
gtest_discover_tests(c_v8_tests)
