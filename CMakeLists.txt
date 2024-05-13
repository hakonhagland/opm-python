cmake_minimum_required (VERSION 3.10)
project(opm-python C CXX)
option(SIBLING_SEARCH "Search for other modules in sibling directories?" ON)
option(OPM_INSTALL_PYTHON "Install python bindings?" ON)
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/modules)
include(OpmPythonFindPython)
include(OpmPythonFindOpmCommon)
include(OpmPythonFindPybind11)
include(OpmPythonOpmInit)
include(OpmPythonOpmLibMain)
include(OpmPythonSetupOpmCommonBindings)
include(OpmPythonGenerateBuiltinKwCpp)

# opm-simulators python bindings
foreach (_file IN LISTS PYTHON_SIMULATORS_CXX_SOURCE_FILES)
   list (APPEND ${opm}_SIMULATORS_CXX_SOURCE_FILES ${PROJECT_SOURCE_DIR}/cxx/simulators/${_file})
endforeach (_file)
set(PYTHON_OPM_SIMULATORS_PACKAGE_PATH ${PROJECT_BINARY_DIR}/python/opm/simulators)

# Set the path to the input docstrings.json file and the output .hpp file
set(PYTHON_DOCSTRINGS_FILE "${PROJECT_SOURCE_DIR}/python/docstrings.json")
set(PYTHON_GENERATED_INCLUDE_DIR "${PROJECT_BINARY_DIR}/cxx/simulators")
set(PYTHON_DOCSTRINGS_GENERATED_HPP "${PYTHON_GENERATED_INCLUDE_DIR}/PyBlackOilSimulatorDoc.hpp")
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
target_include_directories(simulators PRIVATE ${PYTHON_GENERATED_INCLUDE_DIR})

set(PYTHON_PATH ${PROJECT_BINARY_DIR}/python:${opm-common_DIR}/python:$ENV{PYTHONPATH})
# NOTE: To avoid issue wiht MPI_Init() being called after MPI_Finalize(),
#  see PR https://github.com/OPM/opm-simulators/pull/5325  we are
#   splitting the python tests into multiple add_test() tests instead
#   of having a single "python -m unittest" test call that will run all
#   the tests in the "test" sub directory.
foreach(case_name IN ITEMS basic fluidstate_variables primary_variables schedule throw)
  add_test(NAME python_${case_name}
      WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/python
      COMMAND ${CMAKE_COMMAND}
      -E env PYTHONPATH=${PYTHON_PATH} ${PYTHON_EXECUTABLE}
      -m unittest test/test_${case_name}.py)
endforeach()
