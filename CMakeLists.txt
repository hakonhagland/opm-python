cmake_minimum_required (VERSION 3.10)
project(opm-python C CXX)
option(SIBLING_SEARCH "Search for other modules in sibling directories?" ON)
# We need to be compatible with older CMake versions
# that do not offer FindPython3 e.g. Ubuntu LTS 18.04 uses cmake 3.10
if(${CMAKE_VERSION} VERSION_LESS "3.12.0")
  find_package(PythonInterp REQUIRED)
  if(PYTHON_VERSION_MAJOR LESS 3)
    message(SEND_ERROR "OPM requires version 3 of Python but only version ${PYTHON_VERSION_STRING} was found")
  endif()
  set(Python3_EXECUTABLE ${PYTHON_EXECUTABLE})
  set(Python3_LIBRARIES ${PYTHON_LIBRARIES})
  set(Python3_VERSION "${PYTHON_VERSION_STRING}")
  set(Python3_VERSION_MINOR ${PYTHON_VERSION_MINOR})
else()
  # Be backwards compatible.
  if(PYTHON_EXECUTABLE AND NOT Python3_EXECUTABLE)
    set(Python3_EXECUTABLE ${PYTHON_EXECUTABLE})
  endif()
  #set(CMAKE_FIND_DEBUG_MODE TRUE)
  # NOTE: Supply Development or Development.Module to find_package() to get the
  #       the python library location. If you supply Development.Module instead you
  #       will not get the library location for the Python3::Python target:
  #
  #      get_target_property(_lib_path Python3::Python IMPORTED_LOCATION)
  #
  find_package(Python3 REQUIRED COMPONENTS Interpreter Development)
  message(STATUS "Python3_FOUND: ${Python3_FOUND}")
  message(STATUS "Python3_EXECUTABLE: ${Python3_EXECUTABLE}")
  # NOTE: Python3_LIBRARY is empty for some reason, but Python3_LIBRARY_RELEASE is not
  #       so we use that instead.
  message(STATUS "Python3_LIBRARY: ${Python3_LIBRARY_RELEASE}")
  message(STATUS "Python3_VERSION: ${Python3_VERSION}")
  message(STATUS "Python3_INCLUDE_DIRS: ${Python3_INCLUDE_DIRS}")
endif()

if(SIBLING_SEARCH AND NOT opm-common_DIR)
  # guess the sibling dir
  get_filename_component(_leaf_dir_name ${PROJECT_BINARY_DIR} NAME)
  get_filename_component(_parent_full_dir ${PROJECT_BINARY_DIR} DIRECTORY)
  get_filename_component(_parent_dir_name ${_parent_full_dir} NAME)
  #Try if <module-name>/<build-dir> is used
  get_filename_component(_modules_dir ${_parent_full_dir} DIRECTORY)
  if(IS_DIRECTORY ${_modules_dir}/opm-common/${_leaf_dir_name})
    set(opm-common_DIR ${_modules_dir}/opm-common/${_leaf_dir_name})
  else()
    string(REPLACE ${PROJECT_NAME} opm-common _opm_common_leaf ${_leaf_dir_name})
    if(NOT _leaf_dir_name STREQUAL _opm_common_leaf
        AND IS_DIRECTORY ${_parent_full_dir}/${_opm_common_leaf})
      # We are using build directories named <prefix><module-name><postfix>
      set(opm-common_DIR ${_parent_full_dir}/${_opm_common_leaf})
    elseif(IS_DIRECTORY ${_parent_full_dir}/opm-common)
      # All modules are in a common build dir
      set(opm-common_DIR "${_parent_full_dir}/opm-common")
    endif()
  endif()
endif()
if(opm-common_DIR AND NOT IS_DIRECTORY ${opm-common_DIR})
  message(WARNING "Value ${opm-common_DIR} passed to variable"
    " opm-common_DIR is not a directory")
endif()

option(OPM_INSTALL_PYTHON "Install python bindings?" ON)
find_package(opm-common REQUIRED)

# not the same location as most of the other projects; this hook overrides
macro (dir_hook)
endmacro (dir_hook)

# project information is in dune.module. Read this file and set variables.
# we cannot generate dune.module since it is read by dunecontrol before
# the build starts, so it makes sense to keep the data there then.
include (OpmInit)
OpmSetPolicies()

# list of prerequisites for this particular project; this is in a
# separate file (in cmake/Modules sub-directory) because it is shared
# with the find module
include (${project}-prereqs)

# source_hook runs before config_hook and the former needs fmt, hence this
# needs to be here.
if(fmt_FOUND)
  # OpmSatellites will not add the library, do it here.
  list(APPEND opm-common_LIBRARIES fmt::fmt)
else()
  include(DownloadFmt)
endif()

# read the list of components from this file (in the project directory);
# it should set various lists with the names of the files to include
include (CMakeLists_files.cmake)

macro (config_hook)
endmacro(config_hook)

macro (prereqs_hook)
endmacro (prereqs_hook)

macro (sources_hook)
endmacro (sources_hook)

macro (fortran_hook)
endmacro (fortran_hook)

macro (files_hook)
endmacro (files_hook)

macro (tests_hook)
endmacro (tests_hook)

macro (install_hook)
endmacro (install_hook)


get_target_property(_lib_path Python3::Python IMPORTED_LOCATION)
set(PYTHON_LIBRARY ${_lib_path})
set(PYTHON_LIBRARIES {PYTHON_LIBRARY})
find_package(pybind11 2.2 CONFIG)
if (NOT pybind11_FOUND)
  include(DownloadPyBind11)
endif()

# all setup common to the OPM library modules is done here
include (OpmLibMain)
make_directory(${PROJECT_BINARY_DIR}/python)

set(opm-common_PYTHON_PACKAGE_VERSION ${OPM_PYTHON_PACKAGE_VERSION_TAG})
#set(opm-common_SOURCE_DIR ${opm-common_DIR}/..)

add_custom_target(copy_python ALL
  COMMAND ${Python3_EXECUTABLE} ${PROJECT_SOURCE_DIR}/python/install.py ${PROJECT_SOURCE_DIR}/python ${PROJECT_BINARY_DIR} 0)

file(COPY ${PROJECT_SOURCE_DIR}/python/README.md DESTINATION ${PROJECT_BINARY_DIR}/python)
foreach (_file IN LISTS PYTHON_COMMON_CXX_SOURCE_FILES)
   list (APPEND ${opm}_COMMON_CXX_SOURCE_FILES ${PROJECT_SOURCE_DIR}/cxx/common/${_file})
endforeach (_file)
pybind11_add_module(opmcommon_python
                    ${${opm}_COMMON_CXX_SOURCE_FILES}
                    ${opm-common_DIR}/python/cxx/builtin_pybind11.cpp)
target_link_libraries(opmcommon_python PRIVATE
                      opmcommon)
if(TARGET pybind11::pybind11)
  target_link_libraries(opmcommon_python PRIVATE pybind11::pybind11)
else()
  target_include_directories(opmcommon_python SYSTEM PRIVATE ${pybind11_INCLUDE_DIRS})
endif()
set_target_properties(opmcommon_python PROPERTIES LIBRARY_OUTPUT_DIRECTORY python/opm)
add_dependencies(opmcommon_python copy_python)

# Generate versioned setup.py
configure_file(${PROJECT_SOURCE_DIR}/python/setup.py.in
               ${PROJECT_BINARY_DIR}/python/setup.py.tmp)
file(GENERATE OUTPUT ${PROJECT_BINARY_DIR}/python/setup.py
              INPUT ${PROJECT_BINARY_DIR}/python/setup.py.tmp)

# Observe that if the opmcommon library has been built as a shared library the
# python library opmcommon_python will in general not find it runtime while
# testing.
add_test(NAME python_tests
       WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/python
       COMMAND ${CMAKE_COMMAND} -E env LD_LIBRARY_PATH=${opm-common_DIR}/lib ${Python3_EXECUTABLE} -m unittest discover
       )

# opm-simulators python bindings
foreach (_file IN LISTS PYTHON_SIMULATORS_CXX_SOURCE_FILES)
   list (APPEND ${opm}_SIMULATORS_CXX_SOURCE_FILES ${PROJECT_SOURCE_DIR}/cxx/simulators/${_file})
endforeach (_file)
set(PYTHON_OPM_SIMULATORS_PACKAGE_PATH ${PROJECT_BINARY_DIR}/python/opm/simulators)

# Set the path to the input docstrings.json file and the output .hpp file
set(PYTHON_DOCSTRINGS_FILE "${PROJECT_SOURCE_DIR}/python/docstrings.json")
set(PYTHON_DOCSTRINGS_GENERATED_HPP "${PROJECT_BINARY_DIR}/cxx/simulators/PyBlackOilSimulatorDoc.hpp")
file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/cxx/simulators")

# Command to run the Python script to generate the .hpp file
add_custom_command(
   OUTPUT ${PYTHON_DOCSTRINGS_GENERATED_HPP}
   COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${PROJECT_SOURCE_DIR}/python
   ${Python3_EXECUTABLE} ${PROJECT_SOURCE_DIR}/python/generate_docstring_hpp.py
           ${PYTHON_DOCSTRINGS_FILE} ${PYTHON_DOCSTRINGS_GENERATED_HPP}
   DEPENDS ${PYTHON_DOCSTRINGS_FILE}
   COMMENT "Generating PyBlackOilSimulatorDoc.hpp from JSON file"
)

pybind11_add_module(simulators
  ${${opm}_SIMULATORS_CXX_SOURCE_FILES}
  ${PYTHON_DOCSTRINGS_GENERATED_HPP}  # Include the generated .hpp as a source file
  )

set_target_properties( simulators PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${PYTHON_OPM_SIMULATORS_PACKAGE_PATH} )

target_link_libraries( simulators PRIVATE opmsimulators )
# Add the binary (build) directory to the include directories for the target

# Add the build directory where the generated hpp file will be
#  to the include directories for the target
target_include_directories(simulators PRIVATE ${PROJECT_BINARY_DIR}/python)
  