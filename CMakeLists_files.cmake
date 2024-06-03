# This file sets up five lists:
# MAIN_SOURCE_FILES     List of compilation units which will be included in
#                       the library. If it isn't on this list, it won't be
#                       part of the library. Please try to keep it sorted to
#                       maintain sanity.
#
# TEST_SOURCE_FILES     List of programs that will be run as unit tests.
#
# TEST_DATA_FILES       Files from the source three that should be made
#                       available in the corresponding location in the build
#                       tree in order to run tests there.
#
# EXAMPLE_SOURCE_FILES  Other programs that will be compiled as part of the
#                       build, but which is not part of the library nor is
#                       run as tests.
#
# PUBLIC_HEADER_FILES   List of public header files that should be
#                       distributed together with the library. The source
#                       files can of course include other files than these;
#                       you should only add to this list if the *user* of
#                       the library needs it.

list (APPEND MAIN_SOURCE_FILES
  )


list (APPEND TEST_SOURCE_FILES
  )

list (APPEND TEST_DATA_FILES
embedded/tests/PYACTION.DATA
embedded/tests/act1.py
embedded/tests/action_syntax_error.py
embedded/tests/EMBEDDED_PYTHON.DATA
embedded/tests/SPE1CASE1.DATA
embedded/tests/SPE1CASE1_RPTONLY.DATA
embedded/tests/SPE1CASE1_SUMTHIN.DATA
embedded/tests/ACTIONX_M1.DATA
embedded/tests/ACTIONX_M1_MULTIPLE.DATA
embedded/tests/ACTIONX_M1_RESTART.DATA
embedded/tests/ACTIONX_M1.UNRST
embedded/tests/ACTIONX_M1.X0010
embedded/tests/wclose.py
embedded/tests/msim/MSIM_PYACTION.DATA
embedded/tests/msim/MSIM_PYACTION_RETRIEVE_INFO.DATA
embedded/tests/msim/MSIM_PYACTION_CHANGING_SCHEDULE.DATA
embedded/tests/msim/MSIM_PYACTION_CHANGING_SCHEDULE_ACTIONX_CALLBACK.DATA
embedded/tests/msim/MSIM_PYACTION_INSERT_KEYWORD.DATA
embedded/tests/msim/MSIM_PYACTION_INSERT_INVALID_KEYWORD.DATA
embedded/tests/msim/MSIM_PYACTION_NO_RUN_FUNCTION.DATA
embedded/tests/msim/MSIM_PYACTION_OPEN_WELL_AT_PAST_REPORT_STEP.DATA
embedded/tests/msim/MSIM_PYACTION_OPEN_WELL_AT_TOO_LATE_REPORT_STEP.DATA
embedded/tests/msim/MSIM_PYACTION_EXIT.DATA
embedded/tests/EXIT_TEST.DATA
embedded/tests/msim/exit.py
embedded/tests/msim/retrieve_info.py
embedded/tests/msim/action1.py
embedded/tests/msim/action2.py
embedded/tests/msim/action2_no_run_function.py
embedded/tests/msim/action3.py
embedded/tests/msim/action3_actionx_callback.py
embedded/tests/msim/action_count.py
embedded/tests/msim/insert_keyword.py
embedded/tests/msim/insert_invalid_keyword.py
embedded/tests/msim/action_count_no_run_function.py
embedded/tests/msim/open_well_past.py
embedded/tests/msim/open_well_too_late.py
)


list (APPEND PUBLIC_HEADER_FILES
  )

list (APPEND EXAMPLE_SOURCE_FILES
)

list( APPEND PYTHON_COMMON_CXX_SOURCE_FILES
connection.cpp
converters.cpp
deck.cpp
deck_keyword.cpp
eclipse_config.cpp
eclipse_grid.cpp
eclipse_io.cpp
eclipse_state.cpp
emodel_util.cpp
export.cpp
field_props.cpp
group.cpp
log.cpp
parsecontext.cpp
parser.cpp
schedule.cpp
schedule_state.cpp
simulation_config.cpp
summary_state.cpp
table_manager.cpp
unit_system.cpp
well.cpp
)

list( APPEND PYTHON_SIMULATORS_CXX_SOURCE_FILES
Pybind11Exporter.cpp
PyBlackOilSimulator.cpp
)
