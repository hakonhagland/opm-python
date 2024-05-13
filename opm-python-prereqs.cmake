# defines that must be present in config.h for our headers
set (opm-python_CONFIG_VAR
  )

# dependencies
set (opm-python_DEPS
  # Compile with C99 support if available
  "C99"
  # DUNE prerequisites
  "dune-common REQUIRED"
  "dune-istl REQUIRED"
  # OPM dependency
  "opm-common REQUIRED"
  "opm-simulators REQUIRED"
  "fmt 7.0.3"
  )

find_package_deps(opm-python)
# Download fmt if it is not found
if(NOT fmt_FOUND)
  include(DownloadFmt)
endif()
