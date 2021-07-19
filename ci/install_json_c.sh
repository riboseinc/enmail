#!/bin/bash

# (c) Copyright 2021 Ribose Inc.
#

# Based on:
# https://github.com/riboseinc/ruby-rnp/blob/52d6113458cb095cf7811/ci/install.sh

set -eux

: "${MAKE_PARALLEL:=2}"
: "${MAKE:=make}"

jsonc_build="${DEPS_BUILD_DIR}/json-c"

# Copied from rnp:ci/lib/cacheable_install_functions.inc.sh
install_jsonc() {
	local jsonc_build=${LOCAL_BUILDS}/json-c
	if [[ ! -e "${JSONC_INSTALL}/lib/libjson-c.so" ]] && \
		[[ ! -e "${JSONC_INSTALL}/lib/libjson-c.dylib" ]] && \
		[[ ! -e "${JSONC_INSTALL}/lib/libjson-c.a" ]]; then

	if [ -d "${jsonc_build}" ]; then
		rm -rf "${jsonc_build}"
	fi

	mkdir -p "${jsonc_build}"
	pushd "${jsonc_build}"
	wget https://s3.amazonaws.com/json-c_releases/releases/json-c-"${RECOMMENDED_JSONC_VERSION}".tar.gz -O json-c.tar.gz
	tar xzf json-c.tar.gz --strip 1

	autoreconf -ivf
	env CFLAGS="-fno-omit-frame-pointer -Wno-implicit-fallthrough -g" ./configure --prefix="${JSONC_INSTALL}"
	${MAKE} -j"${MAKE_PARALLEL}" install
	popd
	fi
}

export LOCAL_BUILDS="${DEPS_BUILD_DIR}"
export JSONC_INSTALL="${JSONC_PREFIX}"
export RECOMMENDED_JSONC_VERSION="${JSONC_VERSION:-0.12.1}"

install_jsonc
