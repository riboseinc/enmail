#!/bin/bash

# Based on:
# https://github.com/riboseinc/ruby-rnp/blob/52d6113458cb095cf7811/ci/install.sh

set -eux

: "${CORES:=2}"
: "${MAKE:=make}"

botan_build=${LOCAL_BUILDS}/botan
if [ ! -e "${BOTAN_INSTALL}/lib/libbotan-2.so" ] && \
	 [ ! -e "${BOTAN_INSTALL}/lib/libbotan-2.dylib" ]; then

	if [ -d "${botan_build}" ]; then
		rm -rf "${botan_build}"
	fi

	git clone --depth 1 https://github.com/randombit/botan "${botan_build}"
	pushd "${botan_build}"
	./configure.py --prefix="${BOTAN_INSTALL}" --with-debug-info --cxxflags="-fno-omit-frame-pointer"
	${MAKE} -j${CORES} install
	popd
fi
