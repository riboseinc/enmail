FROM ubuntu:xenial

USER root
COPY ci/helpers /helpers

RUN /helpers/system/install-packages.sh
RUN /helpers/system/init_user-root.sh
RUN /helpers/system/init_user-travis.sh
RUN /helpers/system/install-rvm.sh
RUN /helpers/system/install-cmake.sh

RUN apt-get install -y autoconf gcc g++ libbz2-dev libncurses5-dev libtool python wget zlib1g-dev

USER travis
SHELL ["/bin/bash", "-l", "-c"]

############
#   ARGS   #
############
ARG REPO_URL="https://github.com/riboseinc/enmail.git"
ARG REPO_BRANCH="master"
ARG RUBY_VERSION="2.6.3"
ARG GPG_VERSION="latest"
ARG RNP_VERSION="master"

ENV TRAVIS_BUILD_DIR="/home/travis/travis-build"

#ENV EXPECT_GPG_VERSION="2.2"
ENV DEPS_BUILD_DIR="${TRAVIS_BUILD_DIR}/build"
ENV DEPS_PREFIX="${TRAVIS_BUILD_DIR}/opt"
ENV BOTAN_PREFIX="${DEPS_PREFIX}/botan"
ENV JSONC_PREFIX="${DEPS_PREFIX}/json-c"
ENV RNP_PREFIX="${DEPS_PREFIX}/rnp"
ENV GPG_PREFIX="${DEPS_PREFIX}/gpg"
ENV LD_LIBRARY_PATH="${BOTAN_PREFIX}/lib:${JSONC_PREFIX}/lib:${RNP_PREFIX}/lib"
ENV LD_RUN_PATH="${GPG_PREFIX}/lib"
ENV LDFLAGS="-L${GPG_PREFIX}/lib"
ENV GPG_CONFIGURE_OPTS="--disable-doc --enable-pinentry-curses --disable-pinentry-emacs --disable-pinentry-gtk2 --disable-pinentry-gnome3 --disable-pinentry-qt --disable-pinentry-qt4 --disable-pinentry-qt5 --disable-pinentry-tqt --disable-pinentry-fltk --prefix=${GPG_PREFIX} --with-libgpg-error-prefix=${GPG_PREFIX} --with-libassuan-prefix=${GPG_PREFIX} --with-libgpg-error-prefix=${GPG_PREFIX} --with-libgcrypt-prefix=${GPG_PREFIX} --with-libassuan-prefix=${GPG_PREFIX} --with-ksba-prefix=${GPG_PREFIX} --with-npth-prefix=${GPG_PREFIX}"
ENV PATH="${GPG_PREFIX}/bin:${RNP_PREFIX}/bin:${PATH}"

RUN  mkdir -p "${TRAVIS_BUILD_DIR}"
RUN git clone --recursive --depth=50 --branch=${REPO_BRANCH} "${REPO_URL}" "${TRAVIS_BUILD_DIR}"
RUN mkdir -p ${DEPS_PREFIX}
WORKDIR ${TRAVIS_BUILD_DIR}/ci/gpg
RUN ./install_gpg_all.sh --suite-version "${GPG_VERSION}" --build-dir "${DEPS_BUILD_DIR}/gpg" --configure-opts "${GPG_CONFIGURE_OPTS}" --folding-style travis
WORKDIR ${TRAVIS_BUILD_DIR}/ci
RUN ./install_botan.sh
RUN ./install_json_c.sh
RUN ./install_rnp.sh
WORKDIR ${TRAVIS_BUILD_DIR}

RUN rvm use ${RUBY_VERSION} --install --binary --fuzzy --ruby-version
RUN gem install bundler -v "~> 2.0"

#ENV BUNDLE_GEMFILE=$PWD/ci/Mail
RUN bundle install

# Generate OpenPGP test keys
RUN bundle exec rake pgp_keys:generate pgp_keys:list

CMD bundle exec rspec --format documentation --profile 200
