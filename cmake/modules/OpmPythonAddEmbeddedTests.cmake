
function (add_opm_embedded_tests_from_opm_common)
  if (Boost_UNIT_TEST_FRAMEWORK_FOUND)
    set(_libs mocksim opmcommon ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})

    foreach( test msim msim_ACTIONX msim_EXIT)
      set (test_name test_${test})
      opm_add_test(${test_name} SOURCES embedded/tests/msim/${test_name}.cpp
        LIBRARIES ${_libs}
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/embedded/tests
        CONDITION ${HAVE_ECL_INPUT})
      target_include_directories(${test_name} PUBLIC ${opm-common_SOURCE_DIR}/msim/include)
      set_tests_properties(${test} PROPERTIES ENVIRONMENT "${PYTHON_PATH}")
    endforeach()
  endif()
endfunction()

#
#  TODO: This function is part of the opm-simulators file compareECLFiles.cmake and should
#    be refactored out of that file to a new .cmake file in opm-simulators such that
#    it can be included from here (to avoid code duplication).
#
function(add_test_compareSeparateECLFiles)
  set(oneValueArgs CASENAME FILENAME1 FILENAME2 DIR1 DIR2 SIMULATOR ABS_TOL REL_TOL ENVIRONMENT IGNORE_EXTRA_KW DIR_PREFIX)
  set(multiValueArgs TEST_ARGS)
  cmake_parse_arguments(PARAM "$" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
  if(NOT PARAM_PREFIX)
    set(PARAM_PREFIX compareSeparateECLFiles)
  endif()
  set(RESULT_PATH ${BASE_RESULT_PATH}${PARAM_DIR_PREFIX}/${PARAM_SIMULATOR}+${PARAM_CASENAME})
  set(TEST_ARGS ${PARAM_TEST_ARGS})
  set(DRIVER_ARGS -i ${OPM_TESTS_ROOT}/${PARAM_DIR1}
                  -j ${OPM_TESTS_ROOT}/${PARAM_DIR2}
                  -f ${PARAM_FILENAME1}
                  -g ${PARAM_FILENAME2}
                  -r ${RESULT_PATH}
                  -b ${opm-simulators_DIR}/bin
                  -a ${PARAM_ABS_TOL}
                  -t ${PARAM_REL_TOL}
                  -c ${COMPARE_ECL_COMMAND})
  if(PARAM_IGNORE_EXTRA_KW)
    list(APPEND DRIVER_ARGS -y ${PARAM_IGNORE_EXTRA_KW})
  endif()
  set(TEST_NAME ${PARAM_PREFIX}_${PARAM_SIMULATOR}+${PARAM_CASENAME})
  message(STATUS "Adding test ${TEST_NAME}")
  opm_add_test(${TEST_NAME} NO_COMPILE
               EXE_NAME ${PARAM_SIMULATOR}
               DRIVER_ARGS ${DRIVER_ARGS}
               TEST_ARGS ${TEST_ARGS})
  set_tests_properties(${TEST_NAME} PROPERTIES
                        DIRNAME ${PARAM_DIR}
                        FILENAME ${PARAM_FILENAME}
                        SIMULATOR ${PARAM_SIMULATOR}
                        TESTNAME ${PARAM_CASENAME}
                        ENVIRONMENT "${PARAM_ENVIRONMENT}")
endfunction()

function (add_opm_embedded_tests_from_opm_simulators)

  # Regression tests
  opm_set_test_driver(${opm-simulators_SOURCE_DIR}/tests/run-comparison.sh "")

  # Set absolute tolerance to be used passed to the macros in the following tests
  set(abs_tol 1e+5)
  set(rel_tol 2e-5)
  set(coarse_rel_tol 1e-2)
  add_test_compareSeparateECLFiles(CASENAME pyaction_gconprod_insert_kw
                                   DIR1 pyaction
                                   FILENAME1 PYACTION_GCONPROD_INSERT_KW
                                   DIR2 actionx
                                   FILENAME2 ACTIONX_GCONPROD
                                   SIMULATOR flow
                                   ABS_TOL ${abs_tol}
                                   REL_TOL ${rel_tol}
                                   ENVIRONMENT "${PYTHON_PATH}"
                                   IGNORE_EXTRA_KW BOTH)

  add_test_compareSeparateECLFiles(CASENAME pyaction_gconsump_insert_kw
                                   DIR1 pyaction
                                   FILENAME1 PYACTION_GCONSUMP_INSERT_KW
                                   DIR2 actionx
                                   FILENAME2 ACTIONX_GCONSUMP
                                   SIMULATOR flow
                                   ABS_TOL ${abs_tol}
                                   REL_TOL ${rel_tol}
                                   ENVIRONMENT "${PYTHON_PATH}"
                                   IGNORE_EXTRA_KW BOTH)

  add_test_compareSeparateECLFiles(CASENAME pyaction_gruptree_insert_kw
                                   DIR1 pyaction
                                   FILENAME1 PYACTION_GRUPTREE_INSERT_KW
                                   DIR2 actionx
                                   FILENAME2 ACTIONX_GRUPTREE
                                   SIMULATOR flow
                                   ABS_TOL ${abs_tol}
                                   REL_TOL ${rel_tol}
                                   ENVIRONMENT "${PYTHON_PATH}"
                                   IGNORE_EXTRA_KW BOTH)

  add_test_compareSeparateECLFiles(CASENAME pyaction_mult+_insert_kw
                                   DIR1 pyaction
                                   FILENAME1 PYACTION_MULT+_INSERT_KW
                                   DIR2 actionx
                                   FILENAME2 ACTIONX_MULT+
                                   SIMULATOR flow
                                   ABS_TOL ${abs_tol}
                                   REL_TOL ${rel_tol}
                                   ENVIRONMENT "${PYTHON_PATH}"
                                   IGNORE_EXTRA_KW BOTH)

  add_test_compareSeparateECLFiles(CASENAME pyaction_multx+_insert_kw
                                   DIR1 pyaction
                                   FILENAME1 PYACTION_MULTX+_INSERT_KW
                                   DIR2 actionx
                                   FILENAME2 ACTIONX_MULTX+
                                   SIMULATOR flow
                                   ABS_TOL ${abs_tol}
                                   REL_TOL ${rel_tol}
                                   ENVIRONMENT "${PYTHON_PATH}"
                                   IGNORE_EXTRA_KW BOTH)

  add_test_compareSeparateECLFiles(CASENAME pyaction_multx-_insert_kw
                                   DIR1 pyaction
                                   FILENAME1 PYACTION_MULTX-_INSERT_KW
                                   DIR2 actionx
                                   FILENAME2 ACTIONX_MULTX-
                                   SIMULATOR flow
                                   ABS_TOL ${abs_tol}
                                   REL_TOL ${rel_tol}
                                   ENVIRONMENT "${PYTHON_PATH}"
                                   IGNORE_EXTRA_KW BOTH)

  add_test_compareSeparateECLFiles(CASENAME pyaction_next_insert_kw
                                   DIR1 pyaction
                                   FILENAME1 PYACTION_NEXT_INSERT_KW
                                   DIR2 actionx
                                   FILENAME2 ACTIONX_NEXT
                                   SIMULATOR flow
                                   ABS_TOL ${abs_tol}
                                   REL_TOL ${rel_tol}
                                   ENVIRONMENT "${PYTHON_PATH}"
                                   IGNORE_EXTRA_KW BOTH)

  add_test_compareSeparateECLFiles(CASENAME pyaction_wconprod_insert_kw
                                   DIR1 pyaction
                                   FILENAME1 PYACTION_WCONPROD_INSERT_KW
                                   DIR2 actionx
                                   FILENAME2 ACTIONX_WCONPROD
                                   SIMULATOR flow
                                   ABS_TOL ${abs_tol}
                                   REL_TOL ${rel_tol}
                                   ENVIRONMENT "${PYTHON_PATH}"
                                   IGNORE_EXTRA_KW BOTH)

  add_test_compareSeparateECLFiles(CASENAME pyaction_wefac_insert_kw
                                   DIR1 pyaction
                                   FILENAME1 PYACTION_WEFAC_INSERT_KW
                                   DIR2 actionx
                                   FILENAME2 ACTIONX_WEFAC
                                   SIMULATOR flow
                                   ABS_TOL ${abs_tol}
                                   REL_TOL ${rel_tol}
                                   ENVIRONMENT "${PYTHON_PATH}"
                                   IGNORE_EXTRA_KW BOTH)

  add_test_compareSeparateECLFiles(CASENAME pyaction_wesegvalv_insert_kw
                                   DIR1 pyaction
                                   FILENAME1 PYACTION_WSEGVALV_INSERT_KW
                                   DIR2 actionx
                                   FILENAME2 ACTIONX_WSEGVALV
                                   SIMULATOR flow
                                   ABS_TOL ${abs_tol}
                                   REL_TOL ${rel_tol}
                                   ENVIRONMENT "${PYTHON_PATH}"
                                   IGNORE_EXTRA_KW BOTH)

  add_test_compareSeparateECLFiles(CASENAME pyaction_wtest_insert_kw
                                   DIR1 pyaction
                                   FILENAME1 PYACTION_WTEST_INSERT_KW
                                   DIR2 actionx
                                   FILENAME2 ACTIONX_WTEST
                                   SIMULATOR flow
                                   ABS_TOL ${abs_tol}
                                   REL_TOL ${rel_tol}
                                   ENVIRONMENT "${PYTHON_PATH}"
                                   IGNORE_EXTRA_KW BOTH)

endfunction()
# Where to write the test results
function (add_opm_embedded_tests)
  set(BASE_RESULT_PATH ${PROJECT_BINARY_DIR}/embedded/tests/results)
  set(PYTHON_PATH "PYTHONPATH=${PROJECT_BINARY_DIR}/${GENERATED_PROJECT_DIR}/src:$ENV{PYTHONPATH}")
  add_opm_embedded_tests_from_opm_common()
  add_opm_embedded_tests_from_opm_simulators()
endfunction()

add_opm_embedded_tests()

