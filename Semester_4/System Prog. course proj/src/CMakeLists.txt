cmake_minimum_required(VERSION 3.21)
project(my_rescue C)

set(CMAKE_C_STANDARD 11)

set(THREAD_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

add_executable(my_rescue main.c my_logger.h my_mapper.h argument_parser.h rescue.h)
target_link_libraries(my_rescue PRIVATE Threads::Threads)