#!/bin/bash

# (c) Copyright 2018 Ribose Inc.
#

# Based on:
# https://github.com/riboseinc/ruby-rnp/blob/52d6113458cb095cf7811/ci/install.sh

set -eux

: "${CORES:=2}"
: "${RNP_SRC:=${DEPS_BUILD_DIR}/rnp}"
: "${RNP_PREFIX:=/usr/local}"

git clone https://github.com/riboseinc/rnp "${RNP_SRC}"
pushd "${RNP_SRC}"
git checkout "$RNP_VERSION"

cmake \
	-DCMAKE_BUILD_TYPE=RelWithDebInfo \
	-DBUILD_SHARED_LIBS=yes \
	-DBUILD_TESTING=no \
	-DCMAKE_INSTALL_PREFIX="${RNP_PREFIX}" \
	.

make -j${CORES}
sudo make install
popd
