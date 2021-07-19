#!/bin/bash

# (c) Copyright 2018 Ribose Inc.
#

# Based on:
# https://github.com/riboseinc/ruby-rnp/blob/52d6113458cb095cf7811/ci/install.sh

set -eux

: "${MAKE_PARALLEL:=2}"
: "${MAKE:=make}"
: "${BOTAN_MODULES=$(<./botan-modules tr '\n' ',')}"

# Copied from rnp:ci/lib/cacheable_install_functions.inc.sh
install_botan() {
	# botan
	local botan_build=${LOCAL_BUILDS}/botan
	if [[ ! -e "${BOTAN_INSTALL}/lib/libbotan-2.so" ]] && \
		[[ ! -e "${BOTAN_INSTALL}/lib/libbotan-2.dylib" ]] && \
		[[ ! -e "${BOTAN_INSTALL}/lib/libbotan-2.a" ]]; then

	if [[ -d "${botan_build}" ]]; then
		rm -rf "${botan_build}"
	fi

	git clone --depth 1 --branch "${RECOMMENDED_BOTAN_VERSION}" https://github.com/randombit/botan "${botan_build}"
	pushd "${botan_build}"

	./configure.py --prefix="${BOTAN_INSTALL}" --with-debug-info --cxxflags="-fno-omit-frame-pointer" \
		--without-documentation --without-openssl --build-targets=shared \
		--minimized-build --enable-modules="$BOTAN_MODULES"
			${MAKE} -j"${MAKE_PARALLEL}" install
			popd
	fi
}

export LOCAL_BUILDS="${DEPS_BUILD_DIR}"
export BOTAN_INSTALL="${BOTAN_PREFIX}"
export RECOMMENDED_BOTAN_VERSION="${BOTAN_VERSION:-2.17.3}"

install_botan
