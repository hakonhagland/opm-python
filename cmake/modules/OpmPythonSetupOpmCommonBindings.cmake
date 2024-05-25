function (build_opmcommon_pybind11_module)
    foreach (_file IN LISTS PYTHON_COMMON_CXX_SOURCE_FILES)
       list (APPEND ${opm}_COMMON_CXX_SOURCE_FILES
              ${PROJECT_SOURCE_DIR}/pybind11/opmcommon/${_file})
    endforeach (_file)
    pybind11_add_module(${opm-common_PYBIND11_TARGET}
                        ${${opm}_COMMON_CXX_SOURCE_FILES}
                        ${TEMP_GEN_DIR}/builtin_pybind11.cpp)
    target_link_libraries(${opm-common_PYBIND11_TARGET} PRIVATE opmcommon)
    target_include_directories(${opm-common_PYBIND11_TARGET} PRIVATE
                                 ${PROJECT_SOURCE_DIR}/pybind11/opmcommon)

    if(TARGET pybind11::pybind11)
      target_link_libraries(${opm-common_PYBIND11_TARGET} PRIVATE pybind11::pybind11)
    else()
      target_include_directories(${opm-common_PYBIND11_TARGET} SYSTEM PRIVATE
                                 ${pybind11_INCLUDE_DIRS})
    endif()
    set_target_properties(${opm-common_PYBIND11_TARGET} PROPERTIES
          LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${GENERATED_PROJECT_DIR}/src/opm")
endfunction()
build_opmcommon_pybind11_module()


