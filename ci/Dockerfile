FROM ubuntu:xenial AS enmail-builder

USER root
# Apt-get does not play well with -l (https://superuser.com/a/1182104/137385)
SHELL ["/bin/bash", "-c"]

COPY ci/helpers /helpers
RUN /helpers/system/packages.sh
RUN /helpers/system/init_user-root.sh
RUN /helpers/system/init_user-testrunner.sh
RUN /helpers/installers/rvm.sh
RUN /helpers/installers/cmake.sh

USER testrunner
SHELL ["/bin/bash", "-l", "-c"]

############
#   ARGS   #
############
ARG GPG_VERSION="latest"
ARG RNP_VERSION="master"

ENV HOME="/home/testrunner"
ENV BUILD_DIR="${HOME}/enmail"

ENV DEPS_BUILD_DIR="${HOME}/dependencies-src"
ENV GPG_CONFIGURE_OPTS="--disable-doc --enable-pinentry-curses --disable-pinentry-emacs --disable-pinentry-gtk2 --disable-pinentry-gnome3 --disable-pinentry-qt --disable-pinentry-qt4 --disable-pinentry-qt5 --disable-pinentry-tqt --disable-pinentry-fltk --prefix=${GPG_PREFIX} --with-libgpg-error-prefix=${GPG_PREFIX} --with-libassuan-prefix=${GPG_PREFIX} --with-libgpg-error-prefix=${GPG_PREFIX} --with-libgcrypt-prefix=${GPG_PREFIX} --with-libassuan-prefix=${GPG_PREFIX} --with-ksba-prefix=${GPG_PREFIX} --with-npth-prefix=${GPG_PREFIX}"

WORKDIR /helpers/installers
RUN ./botan.sh
RUN ./json_c.sh
RUN ./rnp.sh

WORKDIR /helpers/installers/gpg
RUN ./install_gpg_all.sh --suite-version "${GPG_VERSION}" --sudo --ldconfig --configure-opts "${GPG_CONFIGURE_OPTS}" --build-dir "${DEPS_BUILD_DIR}/gnupg"

RUN git clone https://github.com/rbenv/rbenv.git ${HOME}/.rbenv
RUN mkdir -p ${HOME}/.rbenv/plugins
RUN git clone https://github.com/rbenv/ruby-build.git ${HOME}/.rbenv/plugins/ruby-build

ENV PATH="$HOME/.rbenv/bin:$PATH"
RUN rbenv init -

# ---------------------------------------------------------------------------- #

FROM enmail-builder
USER testrunner
SHELL ["/bin/bash", "-l", "-c"]

ARG RUBY_VERSION="2.6.3"

RUN mkdir -p ${BUILD_DIR}
COPY . ${BUILD_DIR}
WORKDIR ${BUILD_DIR}

RUN rbenv install ${RUBY_VERSION}
RUN rbenv local ${RUBY_VERSION}

#RUN rvm use ${RUBY_VERSION} --install --ruby-version
RUN gem install bundler -v "~> 2.0"

#ENV BUNDLE_GEMFILE=$PWD/ci/Mail
RUN bundle install

# Generate OpenPGP test keys
RUN bundle exec rake pgp_keys:generate pgp_keys:list

CMD bundle exec rspec --format documentation --profile 200
