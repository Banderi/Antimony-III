cmake_minimum_required(VERSION 3.22)

set(CMAKE_CXX_STANDARD 14)

# Included library files
if (ARCH STREQUAL MINGW32)
    set(LIBS_DIR ${CMAKE_SOURCE_DIR}/libs/MINGW/32bit__i686)
elseif(ARCH STREQUAL MINGW64)
    set(LIBS_DIR ${CMAKE_SOURCE_DIR}/libs/MINGW/64bit__amd64)
endif()

### Antimony
project(Antimony3)
set(ANTIMONY_DIR ${PROJECT_SOURCE_DIR}/src/antimony)
add_library(Antimony3
    # Antimony files
    ${ANTIMONY_DIR}/antimony.cpp
    ${ANTIMONY_DIR}/ui/menu.cpp
    ${ANTIMONY_DIR}/core/events.cpp
    ${ANTIMONY_DIR}/input/mouse.cpp
    )
target_include_directories(Antimony3 PRIVATE ${LIBS_DIR}/include)
target_link_directories(Antimony3 PRIVATE ${LIBS_DIR}/lib)
message("Project build set for: ${ARCH}")
message("Library inclusion path: ${LIBS_DIR}")

### Ozymandias
project(Ozymandias2)
set(OZYMANDIAS_DIR ${PROJECT_SOURCE_DIR}/src/ozymandias)
add_executable(Ozymandias2
    # Ozymandias files
    ${OZYMANDIAS_DIR}/main.cpp
    )
target_include_directories(Ozymandias2 PRIVATE ${PROJECT_SOURCE_DIR}/src/antimony)
target_link_directories(Ozymandias2 PRIVATE ${LIBS_DIR}/lib)
target_link_options(Ozymandias2 PRIVATE -static-libgcc -static-libstdc++) # link statically to the C standard libs
target_link_libraries(Ozymandias2 Antimony3) # link to Antimony
target_link_libraries(Ozymandias2 SDL2) # link to SDL2

# Copy binaries from libraries
if(CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
    add_custom_command(
        TARGET Ozymandias2
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${LIBS_DIR}/bin/
        ${CMAKE_CURRENT_BINARY_DIR})
endif()