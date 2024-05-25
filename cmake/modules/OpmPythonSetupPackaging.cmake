# Generate versioned setup.py
configure_file("${PROJECT_SOURCE_DIR}/misc/setup.py.in"
               "${PROJECT_BINARY_DIR}/${TEMP_GEN_DIR}/setup.py.tmp")
file(GENERATE OUTPUT "${PROJECT_BINARY_DIR}/${TEMP_GEN_DIR}/setup.py"
              INPUT "${PROJECT_BINARY_DIR}/${TEMP_GEN_DIR}/setup.py.tmp")
