cmake_minimum_required(VERSION 3.14)

### *********************************** MACROS *****************************************
include(cmake/macros.cmake)

PrintVar(CMAKE_VERSION)
PrintVar(CMAKE_GENERATOR)
PrintVar(WIN32)
PrintVar(ARCH)
PrintVar(CMAKE_BUILD_TYPE)

### ********************************** CPM/LIBS ****************************************
include(cmake/CPM.cmake)
SetVar(CPM_USE_LOCAL_PACKAGES ON)
#SetVar(CPM_LOCAL_PACKAGES_ONLY ON)
#SetVar(CPM_USE_NAMED_CACHE_DIRECTORIES ON)
SetVar(CPM_SOURCE_CACHE .cache/CPM)
# fix for parallel CMake runs over the same folders
file(LOCK ${CPM_SOURCE_CACHE} DIRECTORY GUARD FILE)
# set proper output paths for runtime library files (.dll)
SetVar(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
SetVar(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

### *********************************** CCACHE *****************************************
find_program(CCACHE_TOOL_PATH ccache)
if(NOT WIN32 AND USE_CCACHE AND CCACHE_TOOL_PATH)
    message(STATUS "Using ccache (${CCACHE_TOOL_PATH}) (via wrapper).")
    # see https://github.com/TheLartians/Ccache.cmake enables CCACHE support through
    # the USE_CCACHE flag possible values are: YES, NO or equivalent
    cpmaddpackage("gh:TheLartians/Ccache.cmake@1.2.3")
elseif(WIN32 AND USE_CCACHE AND CCACHE_TOOL_PATH)
    set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE_TOOL_PATH} CACHE STRING "" FORCE)
    set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_TOOL_PATH} CACHE STRING "" FORCE)
    message(STATUS "Using ccache (${CCACHE_TOOL_PATH}).")
endif()

### ******************************* ENGINE TARGETS *************************************
## Antimony III
project(Antimony3 C CXX)
add_library(Antimony3
    # Antimony files
    ${PROJECT_SOURCE_DIR}/src/antimony/antimony.cpp
    ${PROJECT_SOURCE_DIR}/src/antimony/ui/menu.cpp
    ${PROJECT_SOURCE_DIR}/src/antimony/core/events.cpp
    ${PROJECT_SOURCE_DIR}/src/antimony/input/mouse.cpp
    )
AddDependency(Antimony3 SDL2 "gh:libsdl-org/SDL#release-2.0.22")

## Ozymandias 2.0
project(Ozymandias2)
add_executable(Ozymandias2
    # Ozymandias files
    ${PROJECT_SOURCE_DIR}/src/ozymandias/main.cpp
    )
target_include_directories(Ozymandias2 PRIVATE ${CMAKE_SOURCE_DIR}/src/antimony)
target_link_options(Ozymandias2 PUBLIC -static-libgcc -static-libstdc++) # link statically to the C standard libs
target_link_libraries(Ozymandias2 PRIVATE Antimony3) # link to Antimony

## Var prints
GetAllTargets(TargetsList ${CMAKE_SOURCE_DIR})
PrintList(TargetsList "Targets:")
PrintInclusions(Antimony3)
PrintInclusions(Ozymandias2)
#PrintALL()

### ******************************** POST-BUILD ****************************************
## Copy binaries from the libraries on Windows
RecordDLLBinaries(Ozymandias2 SDL2 SDL2.dll)
PrintDLLs()
### Release artifacts
if (CMAKE_BUILD_TYPE STREQUAL Release)
    RecordArtifacts(Ozymandias2)
endif()





