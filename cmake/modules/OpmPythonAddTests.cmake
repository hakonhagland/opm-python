# TODO: Use the opm_add_test() macro in opm-common's OpmSatellites.cmake to add tests
#    instead of using add_test() as below.

add_test(NAME opmcommon_tests
       WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/${GENERATED_PROJECT_DIR}/tests/opmcommon"
       COMMAND ${Python3_EXECUTABLE} ${PROJECT_SOURCE_DIR}/helper_scripts/discover_opmcommon_tests.py)
set_tests_properties(opmcommon_tests PROPERTIES FIXTURES_REQUIRED CopyFilesFixture)
#add_dependencies(test-suite "opmcommon_tests")

# NOTE: To avoid issue wiht MPI_Init() being called after MPI_Finalize(),
#  see PR https://github.com/OPM/opm-simulators/pull/5325  we are
#   splitting the python tests into multiple add_test() tests instead
#   of having a single "python -m unittest" test call that will run all
#   the tests in the "test" sub directory.
foreach(case_name IN ITEMS basic fluidstate_variables primary_variables schedule throw)
  add_test(NAME python_${case_name}
     WORKING_DIRECTORY "${PROJECT_BINARY_DIR}/${GENERATED_PROJECT_DIR}/tests"
     COMMAND ${CMAKE_COMMAND}
       -E env PYTHONPATH=${PROJECT_BINARY_DIR}/${GENERATED_PROJECT_DIR}/src:${PROJECT_BINARY_DIR}/${GENERATED_PROJECT_DIR}/tests
       ${Python3_EXECUTABLE} -m unittest opmsimulators/test_${case_name}.py)
  set_tests_properties(python_${case_name} PROPERTIES FIXTURES_REQUIRED CopyFilesFixture)
  #add_dependencies(test-suite python_${case_name})
endforeach()
