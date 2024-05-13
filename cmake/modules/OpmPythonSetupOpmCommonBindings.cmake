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
                    ${PROJECT_BINARY_DIR}/cxx/common/builtin_pybind11.cpp)
target_link_libraries(opmcommon_python PRIVATE
                      opmcommon)
target_include_directories(opmcommon_python PRIVATE ${PROJECT_SOURCE_DIR}/cxx/common)

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
