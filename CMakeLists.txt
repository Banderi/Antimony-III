cmake_minimum_required(VERSION 3.22)
project(Antimony_III)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_EXE_LINKER_FLAGS "-static-libgcc -static-libstdc++")

add_executable(Antimony_III src/main.cpp)
