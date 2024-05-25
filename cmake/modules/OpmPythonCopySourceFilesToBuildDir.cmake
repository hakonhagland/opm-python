# Usage:
#
#  copy_directory_to_build_dir(
#      TARGET    <target_name>
#      DIRECTORY <directory_name>
#      DESTDIR   <destination_directory_within_the_build_directory>)
#
# Note: If DESTDIR is not provided, the directory will be copied to the top-level
#       build directory.
#
function(copy_directory_to_build_dir)
  # Initialize the options
  set(options)
  set(one_value_args TARGET DIRECTORY DESTDIR)
  set(multi_value_args)
  cmake_parse_arguments(COPY_DIR "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  # Ensure mandatory arguments are provided
  if(NOT COPY_DIR_TARGET)
    message(FATAL_ERROR "TARGET argument is required")
  endif()
  if(NOT COPY_DIR_DIRECTORY)
    message(FATAL_ERROR "DIRECTORY argument is required")
  endif()
  if(NOT COPY_DIR_DESTDIR)
    # Use the top-level build directory if DESTDIR is not provided
    set(COPY_DIR_DESTDIR "")
  endif()

  set(SOURCE_DIR "${CMAKE_SOURCE_DIR}/${COPY_DIR_DIRECTORY}")
  if(COPY_DIR_DESTDIR STREQUAL "")
    set(DEST_DIR "${CMAKE_BINARY_DIR}/${COPY_DIR_DIRECTORY}")
  else()
    set(DEST_DIR "${CMAKE_BINARY_DIR}/${COPY_DIR_DESTDIR}/${COPY_DIR_DIRECTORY}")
  endif()
  # Recursively get all files in the source directory
  file(GLOB_RECURSE SOURCE_FILES "${SOURCE_DIR}/*")
  # Create a unique target name using the directory and destination directory names
  string(REPLACE "/" "_" TMP_DIR_NAME "${COPY_DIR_DIRECTORY}")
  string(REPLACE "/" "_" TMP_DEST_DIR_NAME "${COPY_DIR_DESTDIR}")
  set(COPY_TARGET_NAME "copy_${COPY_DIR_TARGET}_${TMP_DIR_NAME}_${TMP_DEST_DIR_NAME}")

  # Add a custom target to perform the copy
  # NOTE: We could omit "ALL" below, but then the copy target would not necessarily run
  #       during the main build. For example, if TARGET is "test", the copy target would
  #       only run when building the "test" target, not when building the entire project.
  add_custom_target(${COPY_TARGET_NAME} ALL
      COMMAND ${CMAKE_COMMAND} -E make_directory "${DEST_DIR}"
      COMMAND ${CMAKE_COMMAND} -E copy_directory "${SOURCE_DIR}" "${DEST_DIR}"
      DEPENDS ${SOURCE_FILES}
      COMMENT "Copying directory tree ${COPY_DIR_DIRECTORY} to ${DEST_DIR}"
  )

  # Ensure the copy target runs before the actual build
  add_dependencies(${COPY_DIR_TARGET} ${COPY_TARGET_NAME})
endfunction()

add_custom_target(copy_test_files ALL
    COMMAND ${CMAKE_COMMAND} -E echo "Copy test files fixture."
)

copy_directory_to_build_dir(TARGET copy_test_files DIRECTORY tests
                            DESTDIR ${GENERATED_PROJECT_DIR})
copy_directory_to_build_dir(TARGET ${opm-common_PYBIND11_TARGET}
                            DIRECTORY src
                            DESTDIR ${GENERATED_PROJECT_DIR})
add_test(NAME tests_fixture COMMAND ${CMAKE_COMMAND}
          --build ${CMAKE_BINARY_DIR}
          --target copy_test_files)
set_tests_properties(tests_fixture PROPERTIES FIXTURES_SETUP CopyFilesFixture)