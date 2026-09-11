cmake_minimum_required(VERSION 3.16)
project(LoggingExample)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required packages
find_package(PkgConfig REQUIRED)
find_package(Threads REQUIRED)

# Add spdlog
include(FetchContent)
FetchContent_Declare(
    spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog.git
    GIT_TAG v1.12.0
)
FetchContent_MakeAvailable(spdlog)

# Create executable
add_executable(logging_example main.cpp)

# Link libraries
target_link_libraries(logging_example 
    PRIVATE 
    spdlog::spdlog
    Threads::Threads
)

# Compiler-specific options
if(MSVC)
    target_compile_options(logging_example PRIVATE /W4)
else()
    target_compile_options(logging_example PRIVATE -Wall -Wextra -Wpedantic)
endif() 