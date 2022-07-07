cmake_minimum_required(VERSION 3.22)

set(CMAKE_CXX_STANDARD 14)

### SDL2
set(CMAKE_BUILD_TYPE RELEASE)
set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
set(DIRECTX NO) # no idea why this isn't the default for a supposedly cross-platform suite...
add_subdirectory(ext/SDL2)

### Ozymandias
project(Ozymandias2)
set(ANTIMONY_DIR ${PROJECT_SOURCE_DIR}/src/antimony)
set(OZYMANDIAS_DIR ${PROJECT_SOURCE_DIR}/src/ozymandias)
add_executable(Ozymandias2
    # Antimony files
    ${ANTIMONY_DIR}/antimony.cpp
    ${ANTIMONY_DIR}/ui/menu.cpp
    ${ANTIMONY_DIR}/core/events.cpp
    ${ANTIMONY_DIR}/input/mouse.cpp
    # Ozymandias files
    ${OZYMANDIAS_DIR}/main.cpp
    )
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "ozy2") # set executable name
target_include_directories(Ozymandias2 PRIVATE ext) # set inclusion folders for Antimony
target_include_directories(Ozymandias2 PRIVATE src/antimony) # set inclusion folders for Ozymandias
target_link_libraries(Ozymandias2 SDL2-static) # link Ozymandias to SDL2
target_link_options(Ozymandias2 PRIVATE -static-libgcc -static-libstdc++) # link the standard libraries statically
