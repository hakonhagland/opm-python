function (add_opm_embedded_tests)
  if (Boost_UNIT_TEST_FRAMEWORK_FOUND)
    set(_libs mocksim opmcommon ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})

    foreach( test test_msim test_msim_ACTIONX test_msim_EXIT)
      opm_add_test(${test} SOURCES embedded/tests/msim/${test}.cpp
        LIBRARIES ${_libs}
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/embedded/tests
        CONDITION ${HAVE_ECL_INPUT})
      target_include_directories(${test} PUBLIC ${opm-common_SOURCE_DIR}/msim/include)
    endforeach()
    set_tests_properties(msim_ACTIONX PROPERTIES
            ENVIRONMENT "PYTHONPATH=${PROJECT_BINARY_DIR}/opm-python/src:$ENV{PYTHONPATH}")
  endif()
endfunction()
add_opm_embedded_tests()