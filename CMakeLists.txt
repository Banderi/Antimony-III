cmake_minimum_required(VERSION 3.24.0-rc3) # This minimum version is required for FetchContent_Declare(...) to work

set(CMAKE_CXX_STANDARD 14)

#list(APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/libs/MINGW/64bit__amd64")
#find_library(SDL2_LIBRARY NAMES SDL2)
#message(${SDL2_LIBRARY})

### SDL2
#include(FetchContent)
#FetchContent_Declare(
#    SDL2
#    URL  https://www.libsdl.org/release/SDL2-2.0.22.tar.gz
#    FIND_PACKAGE_ARGS
#)
#FetchContent_MakeAvailable(SDL2)

#project(SDL2)
#message("Build type: ${CMAKE_BUILD_TYPE}")
#add_subdirectory("${CMAKE_SOURCE_DIR}/ext/SDL2")
##list(APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/ext/SDL2")
#file(GLOB_RECURSE TEMP_CONFIG_PATH ${CMAKE_CURRENT_BINARY_DIR} SDL2Config.cmake)
#list(APPEND CMAKE_PREFIX_PATH "${TEMP_CONFIG_PATH}")
#message(CMAKE_CURRENT_BINARY_DIR: ${CMAKE_CURRENT_BINARY_DIR})
#message(CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH})
#message(TEMP_CONFIG_PATH: ${TEMP_CONFIG_PATH})
##message(CMAKE_ARCHIVE_OUTPUT_DIRECTORY: ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
##list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_BINARY_DIR}/ext/SDL2")
#find_package(SDL2 REQUIRED)


# Included library files
#set(LIBS_DIR "")
#if (ARCH STREQUAL MINGW32)
##    list(APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/libs/MINGW/32bit__i686")
#    set(LIBS_DIR ${CMAKE_SOURCE_DIR}/libs/MINGW/32bit__i686)
#elseif(ARCH STREQUAL MINGW64)
##    list(APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/libs/MINGW/64bit__amd64")
#    set(LIBS_DIR ${CMAKE_SOURCE_DIR}/libs/MINGW/64bit__amd64)
#elseif(ARCH STREQUAL LINUX)
##    find_library(SDL2)
##    set(LIBS_DIR ${CMAKE_SOURCE_DIR}/libs/MINGW/64bit__amd64)
#endif()
#find_library(SDL2_LIBRARY NAMES SDL2)
#message(${SDL2_LIBRARY})

### Antimony
project(Antimony3)

include(FetchContent)
FetchContent_Declare(
    SDL2
    URL  https://www.libsdl.org/release/SDL2-2.0.22.tar.gz
    FIND_PACKAGE_ARGS
)
FetchContent_MakeAvailable(SDL2)
#find_package(SDL2)
#set(SDL2_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/ext/SDL2/include)
#set(SDL2_LIBRARY SDL2)
#message("SDL2_LIBRARY: ${SDL2_LIBRARY}")
#message("SDL2: ${SDL2}")

get_cmake_property(_variableNames VARIABLES)
list (SORT _variableNames)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
endforeach()

set(ANTIMONY_DIR ${PROJECT_SOURCE_DIR}/src/antimony)
add_library(Antimony3
    # Antimony files
    ${ANTIMONY_DIR}/antimony.cpp
    ${ANTIMONY_DIR}/ui/menu.cpp
    ${ANTIMONY_DIR}/core/events.cpp
    ${ANTIMONY_DIR}/input/mouse.cpp
    )
#target_include_directories(Antimony3 PRIVATE ${SDL2_INCLUDE_DIRS})
target_link_libraries(Antimony3 PUBLIC SDL2)
#message("Project build set for: ${ARCH}")
#message("Library inclusion path: ${LIBS_DIR}")
#message("Build type: ${CMAKE_BUILD_TYPE}")
#message(DLL file: $<TARGET_FILE:SDL2>)

### Ozymandias
project(Ozymandias2)
set(OZYMANDIAS_DIR ${PROJECT_SOURCE_DIR}/src/ozymandias)
add_executable(Ozymandias2
    # Ozymandias files
    ${OZYMANDIAS_DIR}/main.cpp
    )
target_include_directories(Ozymandias2 PRIVATE ${PROJECT_SOURCE_DIR}/src/antimony)
#target_link_directories(Antimony3 PRIVATE ${SDL2_LIBRARIES})
target_link_options(Ozymandias2 PRIVATE -static-libgcc -static-libstdc++) # link statically to the C standard libs
target_link_libraries(Ozymandias2 Antimony3) # link to Antimony
#target_link_libraries(Ozymandias2 SDL2) # link to SDL2

## Copy binaries from the libraries on Windows
if(CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
    add_custom_command(
        TARGET Ozymandias2 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:SDL2> ${CMAKE_CURRENT_BINARY_DIR}
        COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "Copying shared libraries...")
endif()
#
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





