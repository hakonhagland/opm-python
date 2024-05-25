function (generate_pybind11_builtin_kw_cpp)
  set(options)
  set(one_value_args DEPEND_TARGET)
  set(multi_value_args)
  cmake_parse_arguments(GENERATE "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  # Ensure mandatory arguments are provided
  if(NOT GENERATE_DEPEND_TARGET)
    message(FATAL_ERROR "DEPEND_TARGET argument is required")
  endif()

  set(genkw_SOURCES 
     "${opm-common_SOURCE_DIR}/opm/input/eclipse/Generator/KeywordGenerator.cpp"
     "${opm-common_SOURCE_DIR}/opm/input/eclipse/Generator/KeywordLoader.cpp"
     "${PROJECT_SOURCE_DIR}/cmake/cxx/create_pybind11_builtin.cpp")
  add_executable(genkw ${genkw_SOURCES})
  target_link_libraries(genkw ${opm-common_LIBRARIES})

  # Generate keyword list
  set(KW_LIST_CMAKE_FILE
    "${opm-common_SOURCE_DIR}/opm/input/eclipse/share/keywords/keyword_list.cmake")
  include("${KW_LIST_CMAKE_FILE}")
  string(REGEX REPLACE "([^;]+)"
         "${opm-common_SOURCE_DIR}/opm/input/eclipse/share/keywords/\\1"
          keyword_files
          "${keywords}")  # NOTE: quote the list variable to avoid expansion here
  configure_file(
       "${opm-common_SOURCE_DIR}/opm/input/eclipse/keyword_list.argv.in"
       "${PROJECT_BINARY_DIR}/${TEMP_GEN_DIR}/keyword_list.argv")

  # NOTE: the command line arguments to genkw are:
  #
  #  1. The filename with the list of keywords
  #  2. The filename to save the builtin_pybind11.cpp to
  set(GENKW_ARGV
       "${PROJECT_BINARY_DIR}/${TEMP_GEN_DIR}/keyword_list.argv"
       "${PROJECT_BINARY_DIR}/${TEMP_GEN_DIR}/builtin_pybind11.cpp")
  set(GENKW_OUTPUT "${PROJECT_BINARY_DIR}/${TEMP_GEN_DIR}/builtin_pybind11.cpp")
  add_custom_target(
      RunGenkw ALL             # 'ALL' ensures that this target is always built.
      DEPENDS ${GENKW_OUTPUT}  # Depend on the output of the custom command below to ensure it runs.
  )
  add_custom_command(
      OUTPUT ${GENKW_OUTPUT}
      COMMAND ${PROJECT_BINARY_DIR}/bin/genkw ${GENKW_ARGV}
      DEPENDS genkw ${keyword_files} "${KW_LIST_CMAKE_FILE}")
  add_dependencies(${GENERATE_DEPEND_TARGET} RunGenkw)
endfunction()

generate_pybind11_builtin_kw_cpp(DEPEND_TARGET ${opm-common_PYBIND11_TARGET})