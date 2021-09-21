#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./build-aux

set -ex

# NOTE: this configuration duplicates a bunch of effort, because I
#       don't know how to get `pip` to use the current directory
#       for the build - we want to use pip because it handles metadata
#       much better than pure setuptools

# -- install non-python extras

mkdir -p _build
cd _build

# configure
${SRC_DIR}/configure \
	--prefix=${PREFIX} \
;

# build
make -j ${CPU_COUNT}

# test
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]] && [[ "$(uname)" == "Linux" ]];
then  # tests fail on osx...
	make -j ${CPU_COUNT} check V=1 VERBOSE=1
fi

# install
make -j ${CPU_COUNT} install
cd -

# -- build and install python

${PYTHON} -m pip install . -vv
