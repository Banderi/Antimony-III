#cmake_minimum_required(VERSION 3.24.0-rc3) # This minimum version is required for FetchContent_Declare(...) to work
cmake_minimum_required(VERSION 3.14) # This minimum version is required for FetchContent_Declare(...) to work

### *********************************** MACROS *****************************************
function (GetAllTargets out_var current_dir)
    get_property(targets DIRECTORY ${current_dir} PROPERTY BUILDSYSTEM_TARGETS)
    get_property(subdirs DIRECTORY ${current_dir} PROPERTY SUBDIRECTORIES)

    foreach(subdir ${subdirs})
        GetAllTargets(subdir_targets ${subdir})
        list(APPEND targets ${subdir_targets})
    endforeach()

    set(${out_var} ${targets} PARENT_SCOPE)
endfunction()
macro(PrintVar Var)
    message("${Var}: ${${Var}}")
endmacro()
macro(SetVar var value)
    set(${var} ${value})
    PrintVar(${var})
endmacro()
macro(PrintList List ListName)
    message(${ListName})
    foreach(Elem ${${List}})
        message("    ${Elem}")
    endforeach()
endmacro()
macro(PrintALL)
    # print all vars
    get_cmake_property(_variableNames VARIABLES)
    list (SORT _variableNames)
    foreach (_variableName ${_variableNames})
        message(STATUS "${_variableName}=${${_variableName}}")
    endforeach()
endmacro()
macro(PrintLibVals PackageName)
    PrintVar(${PackageName}_FOUND)
    PrintVar(${PackageName}_ADDED)
    PrintVar(${PackageName}_CONFIG)
    PrintVar(${PackageName}_CONSIDERED_CONFIG)
    PrintVar(${PackageName}_CONSIDERED_VERSIONS)
    PrintVar(${PackageName}_SOURCE)
    PrintVar(${PackageName}_SOURCE_DIR)
    PrintVar(${PackageName}_INCLUDE_DIRS)
    PrintVar(${PackageName}_BINARY)
    PrintVar(${PackageName}_BINARY_DIR)
    PrintVar(${PackageName}_DIR)
    PrintVar(${PackageName}_LIBDIR)
    PrintVar(${PackageName}_LIBRARIES)

#    get_target_property(InclusionPaths ${PackageName} INCLUDE_DIRECTORIES)
#    PrintList(InclusionPaths "InclusionPaths:")

#    message(InclusionPaths:)
#    foreach(InclPath ${InclusionPaths})
#        message("    ${InclPath}")
#    endforeach()

endmacro()
#include(FetchContent)
#function(AddLibraryFallback PackageName PackageLocal PackageRemote)
#    message("Attempting to fetch library \"${PackageName}\"...")
#
##    message("1) system installation (find_package)")
##    find_package(${PackageName})
##    if(${${PackageName}_FOUND})
##        PrintLibVals(${PackageName})
##        return()
##    endif()
#
#    message("2) manual installation (${PackageLocal})")
#    find_package(${PackageName} PATHS ${PackageLocal})
#    if(${${PackageName}_FOUND})
#        PrintLibVals(${PackageName})
#        return()
#    endif()
#
#    message("3) fetch and build from source (FetchContent)")
#    FetchContent_Declare(
#        ${PackageName}
#        URL  ${PackageRemote}
#        FIND_PACKAGE_ARGS
#    )
#    FetchContent_MakeAvailable(${PackageName})
#    if(DEFINED ${PackageName}_DIR)
#        PrintLibVals(${PackageName})
#        return()
#    endif()
#
#    message(FATAL_ERROR "ERROR: Could not find ${PackageName} anywhere!")
#endfunction(AddLibraryFallback)

PrintVar(CMAKE_VERSION)
PrintVar(CMAKE_GENERATOR)
PrintVar(WIN32)
PrintVar(ARCH)
PrintVar(CMAKE_BUILD_TYPE)
#PrintALL()

### ********************************* LIBRARIES ****************************************
include(cmake/CPM.cmake)
#PrintVar(CPM_USE_NAMED_CACHE_DIRECTORIES)
#SetVar(CPM_SOURCE_CACHE .cache/CPM)
SetVar(CPM_SOURCE_CACHE .cache/CPM)
# Lock this folder so that parallel CMake runs won't clash on checkout in the same directory
file(LOCK ${CPM_SOURCE_CACHE} DIRECTORY GUARD FILE)
SetVar(CPM_USE_LOCAL_PACKAGES ON)
#SetVar(CPM_LOCAL_PACKAGES_ONLY ON)
#SetVar(CPM_USE_NAMED_CACHE_DIRECTORIES ON)

#if (WIN32)
#    AddLibraryFallback(SDL2
#        "${CMAKE_SOURCE_DIR}/libs/MINGW/64bit__amd64"
#        https://www.libsdl.org/release/SDL2-2.0.22.tar.gz)
#endif()

#function(AddDependency TargetName Visibility PackageName Repo LocalFiles IncludeRelPath)
#    if(NOT ${LocalFiles} STREQUAL Null AND NOT ${IncludeRelPath} STREQUAL Null)
#        message("Searching for local files...")
#        find_library(${PackageName} PATHS ${LocalFiles})
#        PrintLibVals(${PackageName})
#        if(${${PackageName}_FOUND} MATCHES 1)
#            message("Valid lib files found!!")
#            target_include_directories(Antimony3 PUBLIC ${LocalFiles}/${IncludeRelPath})
#            target_link_libraries(${TargetName} ${Visibility} ${PackageName})
#            PrintLibVals(${PackageName})
#            return()
#        endif()
#    endif()
##    if(NOT DEFINED ${${PackageName}_FOUND})
##        message("Using CPM...")
##        CPMAddPackage(${Repo})
##        if(${${PackageName}_ADDED} STREQUAL YES)
##            message(Library successfully fetched!)
##            target_link_libraries(${TargetName} ${Visibility} ${PackageName})
##            PrintLibVals(${PackageName})
##            return()
##        endif()
##    endif()
#endfunction()

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
find_library(SDL2 NAMES SDL2 PATHS "${CMAKE_SOURCE_DIR}/libs/MINGW64")
PrintLibVals(SDL2)
#AddDependency(Antimony3 PUBLIC SDL2 "gh:libsdl-org/SDL#release-2.0.22" "${CMAKE_SOURCE_DIR}/libs/MINGW64" "include/SDL2")

#find_package(SDL2 PATHS ${CMAKE_SOURCE_DIR}/libs/MINGW64)
#if(NOT DEFINED ${${PackageName}_FOUND})
#    message(Using CPM...)
CPMAddPackage(
    NAME SDL2
    GIT_TAG release-2.0.22
    GITHUB_REPOSITORY libsdl-org/SDL
#    FIND_PACKAGE_ARGUMENTS
#    "REQUIRED PATHS ${CMAKE_SOURCE_DIR}/libs/MINGW64"
)
#else()
#    target_include_directories(Antimony3 PUBLIC ${CMAKE_SOURCE_DIR}/libs/MINGW64/include/SDL2)
#endif()
#
##PrintALL()
##PrintVar(CMAKE_INSTALL_PREFIX)
#PrintLibVals(SDL2)
target_link_libraries(Antimony3 PUBLIC SDL2)
#target_include_directories(Antimony3 PUBLIC ${CMAKE_SOURCE_DIR}/test)
#target_include_directories(Antimony3 PUBLIC ${CMAKE_SOURCE_DIR}/test2)
#target_include_directories(Antimony3 PUBLIC ${CMAKE_SOURCE_DIR}/libs/MINGW64/include/SDL2)

get_target_property(InclusionPaths Antimony3 INCLUDE_DIRECTORIES)
PrintList(InclusionPaths "Inclusion paths:")
GetAllTargets(TargetsList ${CMAKE_SOURCE_DIR})
PrintList(TargetsList "Targets:")

## Ozymandias 2.0
project(Ozymandias2)
add_executable(Ozymandias2
    # Ozymandias files
    ${PROJECT_SOURCE_DIR}/src/ozymandias/main.cpp
    )
target_include_directories(Ozymandias2 PRIVATE ${CMAKE_SOURCE_DIR}/src/antimony)
target_link_options(Ozymandias2 PUBLIC -static-libgcc -static-libstdc++) # link statically to the C standard libs
target_link_libraries(Ozymandias2 PRIVATE Antimony3) # link to Antimony

### ******************************** POST-BUILD ****************************************
## Copy binaries from the libraries on Windows
if(WIN32)
    add_custom_command(
        TARGET Ozymandias2 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:SDL2> ${CMAKE_CURRENT_BINARY_DIR}
        COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "Copying shared libraries...")
endif()
### Release artifacts
#if (CMAKE_BUILD_TYPE STREQUAL Release)
#    set(ARTIFACT_DIR ${CMAKE_SOURCE_DIR}/artifacts)
#    file(MAKE_DIRECTORY ${ARTIFACT_DIR})
#    if(WIN32)
#        add_custom_command(
#            TARGET Ozymandias2 POST_BUILD
#            COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:SDL2> ${ARTIFACT_DIR}
#            COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:Ozymandias2> ${ARTIFACT_DIR}
#            COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "Copying artifacts...")
#    endif()
#endif()





