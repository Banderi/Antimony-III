cmake_minimum_required(VERSION 3.24.0-rc3) # This minimum version is required for FetchContent_Declare(...) to work

set(CMAKE_CXX_STANDARD 14)

### ********************************* LIBRARIES ****************************************
include(FetchContent)
FetchContent_Declare(
    SDL2
    URL  https://www.libsdl.org/release/SDL2-2.0.22.tar.gz
    FIND_PACKAGE_ARGS
)
FetchContent_MakeAvailable(SDL2)

### ****************************** ENGINE BUILDING *************************************

project(Antimony3) # Antimony III
set(ANTIMONY_DIR ${PROJECT_SOURCE_DIR}/src/antimony)
add_library(Antimony3
    # Antimony files
    ${ANTIMONY_DIR}/antimony.cpp
    ${ANTIMONY_DIR}/ui/menu.cpp
    ${ANTIMONY_DIR}/core/events.cpp
    ${ANTIMONY_DIR}/input/mouse.cpp
    )
target_link_libraries(Antimony3 PUBLIC SDL2)

project(Ozymandias2) # Ozymandias 2.0
set(OZYMANDIAS_DIR ${PROJECT_SOURCE_DIR}/src/ozymandias)
add_executable(Ozymandias2
    # Ozymandias files
    ${OZYMANDIAS_DIR}/main.cpp
    )
target_include_directories(Ozymandias2 PRIVATE ${PROJECT_SOURCE_DIR}/src/antimony)
target_link_options(Ozymandias2 PUBLIC -static-libgcc -static-libstdc++) # link statically to the C standard libs
target_link_libraries(Ozymandias2 Antimony3) # link to Antimony

### ******************************** POST-BUILD ****************************************
## Copy binaries from the libraries on Windows
if(CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
    add_custom_command(
        TARGET Ozymandias2 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:SDL2> ${CMAKE_CURRENT_BINARY_DIR}
        COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "Copying shared libraries...")
endif()
## Release artifacts
if (CMAKE_BUILD_TYPE STREQUAL Release)
    set(ARTIFACT_DIR ${CMAKE_SOURCE_DIR}/artifacts)
    file(MAKE_DIRECTORY ${ARTIFACT_DIR})
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
        add_custom_command(
            TARGET Ozymandias2 POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:SDL2> ${ARTIFACT_DIR}
            COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:Ozymandias2> ${ARTIFACT_DIR}
            COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "Copying artifacts...")
    endif()
endif()





