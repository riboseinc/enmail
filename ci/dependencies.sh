#!/bin/bash

set -eux

# For better performance, skip Homebrew auto updates.
# Travis CI updates their images from time to time, anyway.
export HOMEBREW_NO_AUTO_UPDATE=1

# For simplicity, all software dependenies are declared in this very file.

# Install RNP
brew tap riboseinc/rnp
brew install rnp

# Install GnuPG
# - for latest version, use Homebrew
# - for older versions, use Ribose's GnuPG build scripts
if [[ "$GPG_VERSION" == "latest" ]]; then
	brew install gnupg
else
	pushd ${TRAVIS_BUILD_DIR}/ci/gpg

	# Install to /usr/local
	export GPG_PREFIX="/usr/local"

	export GPG_BUILD_DIR="${HOME}/build/gpg"

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
		--build-dir "${GPG_BUILD_DIR}" \
		--configure-opts "${GPG_CONFIGURE_OPTS}" \
		--folding-style travis
	popd
fi
