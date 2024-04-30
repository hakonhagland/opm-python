# opm-python-test

Testing repository for `opm-python`. The plan is to create a repository https://github.com/OPM/opm-python/ that will build Python bindings for `opm-common` and `opm-simulators`. This repository `opm-python-test` is used to discuss and prepare the implementation of the `opm-python` repository.

## To build opm-python-test

```
#! /bin/bash

NPROC=5  # Number of build threads when running "make"

build_opm_common() {
   # NOTE: Currently we need to build opm-common with -DOPM_ENABLE_PYTHON=ON to
   #  extract the generated file builtin_pybind11.cpp
   # TODO: Build this file within opm-python-test instead and then build
   #  opm-common with -DOPM_ENABLE_PYTHON=OFF instead
   local flags="-DBUILD_SHARED_LIBS=ON -DOPM_ENABLE_PYTHON=ON -DBUILD_SHARED_LIBS=ON"
   git clone git@github.com:OPM/opm-common.git
   cd opm-common
   mkdir build
   cd build
   cmake $flags ..
   make -j$NPROC
   cd ../..
}

build_opm_grid() {
   local flags=""
   git clone git@github.com:OPM/opm-grid.git
   cd opm-grid
   mkdir build
   cd build
   cmake $flags ..
   make -j$NPROC
   cd ../..
}

build_opm_models() {
   local flags=""
   git clone git@github.com:OPM/opm-models.git
   cd opm-models
   mkdir build
   cd build
   cmake $flags ..
   make -j$NPROC
   cd ../..
}

build_opm_simulators() {
   local flags="-DBUILD_SHARED_LIBS=ON -DOPM_ENABLE_PYTHON=OFF -DBUILD_SHARED_LIBS=ON"
   git clone git@github.com:OPM/opm-simulators.git
   cd opm-simulators
   mkdir build
   cd build
   cmake $flags ..
   make -j$NPROC
   cd ../..
}

build_opm_python() {
   local flags=""
   git clone git@github.com:hakonhagland/opm-python-test.git
   cd opm-python-test
   mkdir build
   cd build
   cmake $flags ..
   make -j$NPROC
   cd ../..
}

build_opm_common
build_opm_grid
build_opm_models
build_opm_simulators
build_opm_python
```
