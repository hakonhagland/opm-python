# opm-python-test

Testing repository for `opm-python`.

The plan is to create a repository https://github.com/OPM/opm-python/ that will build Python bindings for `opm-common` and `opm-simulators`.
As a first stage in this plan, the current repository `opm-python-test` was created for discussing and preparing the implementation of the `opm-python` repository.

## To build opm-python-test

- Note that we are not able to build with shared libraries yet, see https://github.com/OPM/opm-simulators/issues/5390.

- We need to enable embedded Python in `opm-common` in order to run the PYACTION test cases.

- Build script:

```
#! /bin/bash

NPROC=5  # Number of build threads when running "make"

for repo in opm-common opm-grid opm-models opm-simulators
do
    git clone git@github.com:OPM/"${repo}".git
done
git clone git@github.com:hakonhagland/opm-python-test.git

build_opm_common() {
   local flags="-DBUILD_SHARED_LIBS=OFF -DOPM_ENABLE_PYTHON=ON -DOPM_ENABLE_EMBEDDED_PYTHON=ON"
   cd opm-common
   mkdir build
   cd build
   cmake $flags ..
   make -j$NPROC
   cd ../..
}

build_opm_grid() {
   local flags="-DBUILD_SHARED_LIBS=OFF"
   cd opm-grid
   mkdir build
   cd build
   cmake $flags ..
   make -j$NPROC
   cd ../..
}

build_opm_models() {
   local flags="-DBUILD_SHARED_LIBS=OFF"
   cd opm-models
   mkdir build
   cd build
   cmake $flags ..
   make -j$NPROC
   cd ../..
}

build_opm_simulators() {
   local flags="-DBUILD_SHARED_LIBS=OFF"
   cd opm-simulators
   mkdir build
   cd build
   cmake $flags ..
   make -j$NPROC
   cd ../..
}

build_opm_python() {
   # If you want to run integration tests from opm-tests add path below, e.g.
   # local flags="-DOPM_TESTS_ROOT=<path to opm-tests>"
   local flags=""
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
## Current state

- Unit tests are working

## TODO

- Implement cmake "make install" procedure
- Implement GitHub actions to build sphinx docs
- Implement GitHub actions to run unit tests
- Implement workflow to publish "opm" as PyPI package
