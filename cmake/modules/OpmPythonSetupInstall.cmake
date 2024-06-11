# SYNOPSIS
# --------
#  get_python_install_prefix(OUTPUT_VARIABLE prefix)
#
# DESCRIPTION
# -----------
#  This function determines the installation prefix for Python modules.
#
#  The output variable `prefix` will be set to the installation prefix for Python
#  modules. This is determined by the following rules:
#
#  1. If the Python site-packages directory is a subdirectory of the system
#     package directory (e.g. /usr/lib/python2.7/dist-packages), then the
#     installation prefix is `lib/<python_version>/dist-packages`.
#
#  2. Otherwise, the installation prefix is `lib/<python_version>/site-packages`.
#
function (get_python_install_prefix)
  cmake_parse_arguments(ARG "" "OUTPUT_VARIABLE" "" ${ARGN})

  if (NOT ARG_OUTPUT_VARIABLE)
      message(FATAL_ERROR "get_python_install_prefix: OUTPUT_VARIABLE argument is required.")
  endif()
  execute_process(COMMAND ${Python3_EXECUTABLE} -c "
  import site, sys
  try:
      sys.stdout.write(site.getsitepackages()[-1])
  except e:
      sys.stdout.write('')" OUTPUT_VARIABLE PYTHON_SITE_PACKAGES_PATH)
    # -------------------------------------------------------------------------
    # 1: Wrap C++ functionality in Python
  if (PYTHON_SITE_PACKAGES_PATH MATCHES ".*/dist-packages/?" AND
      CMAKE_INSTALL_PREFIX MATCHES "^/usr.*")
    # dist-packages is only used if we install below /usr and python's site packages
    # path matches dist-packages
    set(PYTHON_PACKAGE_PATH "dist-packages")
  else()
    set(PYTHON_PACKAGE_PATH "site-packages")
  endif()
  if(PYTHON_VERSION_MAJOR)
    set(PY_MAJOR ${PYTHON_VERSION_MAJOR})
  else()
    set(PY_MAJOR ${Python3_VERSION_MAJOR})
  endif()
  if(PYTHON_VERSION_MINOR)
    set(PY_MINOR ${PYTHON_VERSION_MINOR})
  else()
    set(PY_MINOR ${Python3_VERSION_MINOR})
  endif()
  # Return the install prefix in the supplied variable
  set(${ARG_OUTPUT_VARIABLE} "lib/python${PY_MAJOR}.${PY_MINOR}/${PYTHON_PACKAGE_PATH}" PARENT_SCOPE)
endfunction()

function (install_python_modules)
  get_python_install_prefix(OUTPUT_VARIABLE PYTHON_INSTALL_PREFIX)
  # Since the installation of Python code is nonstandard it is protected by an
  # extra cmake switch, OPM_INSTALL_PYTHON. If you prefer you can still invoke
  # setup.py install manually - optionally with the generated script
  # setup-install.sh - and completely bypass cmake in the installation phase.
  if (OPM_INSTALL_PYTHON)
    set(PYTHON_INSTALL_PY "${PROJECT_SOURCE_DIR}/helper_scripts/install.py")
    install(
      CODE "execute_process(
        COMMAND ${Python3_EXECUTABLE}
                ${PYTHON_INSTALL_PY}
                ${PROJECT_BINARY_DIR}/${GENERATED_PROJECT_DIR}/src/opm
                ${DEST_PREFIX}${CMAKE_INSTALL_PREFIX}/${PYTHON_INSTALL_PREFIX} 1)")
    install(
      CODE "execute_process(
        COMMAND ${Python3_EXECUTABLE}
                ${PYTHON_INSTALL_PY}
                ${PROJECT_BINARY_DIR}/${GENERATED_PROJECT_DIR}/src/opm_embedded
                ${DEST_PREFIX}${CMAKE_INSTALL_PREFIX}/${PYTHON_INSTALL_PREFIX} 1)")
  endif()
endfunction()

install_python_modules()
