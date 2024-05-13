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
