cmake_minimum_required(VERSION 3.14)

### *********************************** MACROS *****************************************
include(cmake/macros.cmake)

PrintVar(CMAKE_VERSION)
PrintVar(CMAKE_GENERATOR)
PrintVar(WIN32)
PrintVar(ARCH)
PrintVar(CMAKE_BUILD_TYPE)

### ********************************** CPM/LIBS ****************************************
SetVar(CPM_USE_LOCAL_PACKAGES ON)
#SetVar(CPM_LOCAL_PACKAGES_ONLY ON)
#SetVar(CPM_USE_NAMED_CACHE_DIRECTORIES ON)
PrintVar(CPM_SOURCE_CACHE)
# fix for parallel CMake runs over the same folders
if(DEFINED ${CPM_SOURCE_CACHE})
    file(LOCK ${CPM_SOURCE_CACHE} DIRECTORY GUARD FILE)
endif()
# set proper output paths for runtime library files (.dll)
SetVar(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
SetVar(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
include(cmake/CPM.cmake)

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

### ******************************* PROJECT TARGETS ************************************
## Antimony III
project(Antimony3 C CXX)
message("\n### ******************************** ANTIMONY ****************************************")
SetVar(PROJECT_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/antimony)
add_library(Antimony3
    # Antimony files
    ${PROJECT_SOURCE_DIR}/antimony.cpp
    ${PROJECT_SOURCE_DIR}/ui/menu.cpp
    ${PROJECT_SOURCE_DIR}/core/events.cpp
    ${PROJECT_SOURCE_DIR}/input/mouse.cpp
    )
target_include_directories(Antimony3 PUBLIC ${CMAKE_SOURCE_DIR}/src) # for GID

IncludePrebuilt(SDL2) # this checks the pre-built files supplied by the ${PackageName}_PREBUILT variable
if (NOT USING_PREBUILT_SDL2)
    # otherwise, just use CPM
    # (it will first scan for system-installed libs, if the option is enabled)
    CPMAddPackage(GITHUB_REPOSITORY libsdl-org/SDL
        GIT_TAG release-2.0.22
        OPTIONS
        "SDL2_DISABLE_INSTALL TRUE")
endif()
if(SDL_ADDED)
    message("# Since SDL was imported and build from source code, we try to \"soft install\" the header files ourselves...")
    SET(SDL_HEADERS_SOFT_INSTALL_DIR ${CMAKE_BINARY_DIR}/SDLHeaders/include)
    message("# Headers folder set to: ${SDL_HEADERS_SOFT_INSTALL_DIR}/SDL2")
    # Copy all non-generated headers to ".../include/SDL2"
    # This is done to avoid the inclusion of a pre-generated SDL_config.h
    file(GLOB SDL_INCLUDE_FILES ${SDL_SOURCE_DIR}/include/*.h)
    set(SDL_COPIED_INCLUDE_FILES)
    foreach(_hdr IN LISTS SDL_INCLUDE_FILES)
        if(_hdr MATCHES ".*(SDL_config|SDL_revision).*")
            # Ignore SDL_config.h and SDL_revision.h
            list(REMOVE_ITEM SDL_INCLUDE_FILES "${_hdr}")
        else()
            # Copy valid file over
            get_filename_component(_name "${_hdr}" NAME)
            message("Copying ${_name}...")
            FILE(COPY ${_hdr} DESTINATION ${SDL_HEADERS_SOFT_INSTALL_DIR}/SDL2)
        endif()
    endforeach()
    target_include_directories(Antimony3 PUBLIC ${SDL_HEADERS_SOFT_INSTALL_DIR})
endif()
target_link_libraries(Antimony3 PUBLIC SDL2)
PrintLibVars(SDL2)

## Ozymandias 2.0
project(Ozymandias2)
message("\n### ******************************** OZYMANDIAS ****************************************")
SetVar(PROJECT_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/ozymandias)
add_executable(Ozymandias2
    # Ozymandias files
    ${PROJECT_SOURCE_DIR}/main.cpp
    )
target_include_directories(Ozymandias2 PRIVATE ${CMAKE_SOURCE_DIR}/src/antimony)
target_link_options(Ozymandias2 PUBLIC -static-libgcc -static-libstdc++) # link statically to the C standard libs
target_link_libraries(Ozymandias2 PRIVATE Antimony3) # link to Antimony

### ******************************** POST-BUILD ****************************************
message("\n### ******************************** POST-BUILD ****************************************")
## Copy binaries from the libraries on Windows
RecordDLLBinaries(Ozymandias2 SDL2 SDL2.dll)
PrintDLLs()
### Release artifacts
if (CMAKE_BUILD_TYPE STREQUAL Release)
    RecordArtifacts(Ozymandias2)
endif()

### ******************************** VAR PRINTS ****************************************
message("\n### ******************************** SUMMARY ****************************************")
GetAllTargets(TargetsList ${CMAKE_SOURCE_DIR})
PrintList(TargetsList "Targets:")
foreach(Target ${TargetsList})
    PrintInclusions(${Target})
endforeach()
#PrintALL()
message("")



