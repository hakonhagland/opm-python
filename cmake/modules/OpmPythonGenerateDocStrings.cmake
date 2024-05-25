# Set the path to the input docstrings.json file and the output .hpp file
set(PYTHON_DOCSTRINGS_FILE "${PROJECT_SOURCE_DIR}/docs/docstrings.json")
set(DOCSTRINGS_GENERATED_HPP "PyBlackOilSimulatorDoc.hpp")
set(DOCSTRINGS_GENERATED_HEADER_PATH "${PROJECT_BINARY_DIR}/${TEMP_GEN_DIR}/${DOCSTRINGS_GENERATED_HPP}")

# Command to run the Python script to generate the .hpp file
add_custom_command(
   OUTPUT ${DOCSTRINGS_GENERATED_HEADER_PATH}
   COMMAND ${Python3_EXECUTABLE} ${PROJECT_SOURCE_DIR}/helper_scripts/generate_docstring_hpp.py ${PYTHON_DOCSTRINGS_FILE} "${DOCSTRINGS_GENERATED_HEADER_PATH}"
   DEPENDS ${PYTHON_DOCSTRINGS_FILE}
   COMMENT "Generating ${DOCSTRINGS_GENERATED_HPP} from JSON file"
)

# Create a custom target for the generated header file
add_custom_target(generate_docstring_hpp DEPENDS ${DOCSTRINGS_GENERATED_HEADER_PATH})
