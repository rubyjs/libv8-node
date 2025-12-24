cmake_minimum_required(VERSION 3.14)
project(gtest)

# V8 requires at least C++20
set(CMAKE_CXX_STANDARD 20)

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

string(TOLOWER ${CMAKE_SYSTEM_NAME} system_name)
if(APPLE AND CMAKE_OSX_ARCHITECTURES)
  string(TOLOWER ${CMAKE_OSX_ARCHITECTURES} system_arch)
else()
  string(TOLOWER ${CMAKE_SYSTEM_PROCESSOR} system_arch)
endif()

if(system_arch STREQUAL "aarch64")
  set(system_arch "arm64")
endif()

set(vendor_arch "${system_arch}-${system_name}")

if(${system_name} STREQUAL "linux")
	try_compile(is_glibc ${CMAKE_BINARY_DIR}/check_glibc ${CMAKE_SOURCE_DIR}/check_glibc.c)
	if(NOT is_glibc)
		# assume non-glibc is musl-libc
		string(APPEND vendor_arch "-musl")
	endif()
endif()

if(APPLE)
  find_library(CoreFoundation CoreFoundation)
endif()

message(STATUS "Detected vendor architecture directory: ${vendor_arch}")

# TODO?: Detect and support ruby-arch builds?
target_link_libraries(c_v8_tests ${CMAKE_SOURCE_DIR}/../../vendor/v8/${vendor_arch}/libv8/obj/libv8_monolith.a)

# This has to be after the v8 monolith for some build setups.
target_link_libraries(c_v8_tests dl)

target_link_libraries(c_v8_tests $<$<PLATFORM_ID:Darwin>:${CoreFoundation}>)

include(GoogleTest)
gtest_discover_tests(c_v8_tests)
