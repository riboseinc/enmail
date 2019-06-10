#!/bin/bash

# (c) Copyright 2018 Ribose Inc.
#

set -eux

pushd gpg

export GPG_PREFIX="/usr/local"
export GPG_BUILD_DIR="${DEPS_BUILD_DIR}/gpg"

export GPG_CONFIGURE_OPTS="--disable-doc \
	--enable-pinentry-curses \
	--disable-pinentry-emacs \
	--disable-pinentry-gtk2 \
	--disable-pinentry-gnome3 \
	--disable-pinentry-qt \
	--disable-pinentry-qt4 \
	--disable-pinentry-qt5 \
	--disable-pinentry-tqt \
	--disable-pinentry-fltk \
	--prefix=${GPG_PREFIX} \
	--with-libgpg-error-prefix=${GPG_PREFIX} \
	--with-libassuan-prefix=${GPG_PREFIX} \
	--with-libgpg-error-prefix=${GPG_PREFIX} \
	--with-libgcrypt-prefix=${GPG_PREFIX} \
	--with-libassuan-prefix=${GPG_PREFIX} \
	--with-ksba-prefix=${GPG_PREFIX} \
	--with-npth-prefix=${GPG_PREFIX}"

./install_gpg_all.sh \
	--suite-version "${GPG_VERSION}" \
	--sudo \
	--ldconfig \
	--build-dir "${GPG_BUILD_DIR}" \
	--configure-opts "${GPG_CONFIGURE_OPTS}"

popd # gpg
