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
macro(PrintLibVars PackageName)
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
macro(PrintInclusions Target)
  get_target_property(InclusionPaths ${Target} INCLUDE_DIRECTORIES)
  PrintList(InclusionPaths "${Target} inclusion paths:")
endmacro()
macro(PrintDLLs)
  get_property(DLLBinariesList GLOBAL PROPERTY DLLBinariesList_GLOBAL)
  PrintList(DLLBinariesList "Shared library files:")
endmacro()

function (GetAllTargets out_var current_dir)
  get_property(targets DIRECTORY ${current_dir} PROPERTY BUILDSYSTEM_TARGETS)
  get_property(subdirs DIRECTORY ${current_dir} PROPERTY SUBDIRECTORIES)

  foreach(subdir ${subdirs})
    GetAllTargets(subdir_targets ${subdir})
    list(APPEND targets ${subdir_targets})
  endforeach()

  set(${out_var} ${targets} PARENT_SCOPE)
endfunction()
function(AddDependency TargetName PackageName CPMUri)
  if (DEFINED ${PackageName}_PREBUILT)
    # first check if the <PackageName>_PREBUILT variable has been set, and use that one if so
    target_include_directories(Antimony3 PUBLIC ${${PackageName}_PREBUILT}/include/${PackageName})
    target_link_directories(Antimony3 PUBLIC ${${PackageName}_PREBUILT}/lib)
  else()
    # otherwise, just use CPM
    # (it will first scan for system-installed libs, if the option is enabled)
    CPMAddPackage(${CPMUri})
  endif()
  target_link_libraries(${TargetName} PUBLIC ${PackageName})
  PrintLibVars(${PackageName})
endfunction()
function(RecordDLLBinaries TargetName PackageName BinaryFileName)
  # read from GLOBAL... :(
  get_property(DLLBinariesList GLOBAL PROPERTY DLLBinariesList_GLOBAL)

  # record the dependency binaries
  if(TARGET ${PackageName})
    list(APPEND DLLBinariesList $<TARGET_FILE:${PackageName}>)
  elseif(DEFINED ${PackageName}_PREBUILT)
    get_filename_component(temp "${${PackageName}_PREBUILT}/bin/${BinaryFileName}"
        REALPATH BASE_DIR "${CMAKE_SOURCE_DIR}")
    list(APPEND DLLBinariesList ${temp})
  endif()

  # set back to GLOBAL... :(
  set_property(GLOBAL PROPERTY DLLBinariesList_GLOBAL "${DLLBinariesList}")

  # add custom commands to copy over .dll files (necessary for Windows)
  if(WIN32)
    foreach(Dep ${DLLBinariesList})
      add_custom_command(
          TARGET ${TargetName} POST_BUILD
          COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "Copying DLL file: ${Dep}"
          COMMAND ${CMAKE_COMMAND} -E copy_if_different ${Dep} ${CMAKE_CURRENT_BINARY_DIR})
    endforeach()
  endif()
endfunction()
function(RecordArtifacts TargetName)
  # read from GLOBAL... :(
  get_property(DLLBinariesList GLOBAL PROPERTY DLLBinariesList_GLOBAL)

  set(ARTIFACT_DIR ${CMAKE_SOURCE_DIR}/artifacts)
  # create artifacts folder and copy the executables
  add_custom_command(
      TARGET ${TargetName} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E make_directory ${ARTIFACT_DIR}
      COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "Copying artifact: $<TARGET_FILE:${TargetName}>"
      COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${TargetName}> ${ARTIFACT_DIR})
  # copy over the dependencies
  if(WIN32)
    foreach(Dep ${DLLBinariesList})
      add_custom_command(
          TARGET ${TargetName} POST_BUILD
          COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "Copying artifact: ${Dep}"
          COMMAND ${CMAKE_COMMAND} -E copy_if_different ${Dep} ${ARTIFACT_DIR})
    endforeach()
  endif()
endfunction()