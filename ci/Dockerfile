# The freshest distro is preferred, because RNP relies on recent features of
# Botan, CMake, JSON-C, etc.
FROM ubuntu:rolling AS enmail-builder

USER root
# Apt-get does not play well with -l (https://superuser.com/a/1182104/137385)
SHELL ["/bin/bash", "-c"]

COPY ci/helpers /helpers
RUN /helpers/system/packages.sh
RUN /helpers/system/init_user-root.sh
RUN /helpers/system/init_user-testrunner.sh

USER testrunner
SHELL ["/bin/bash", "-l", "-c"]
ENV HOME="/home/testrunner"

###   ARGS   ###
ARG GPG_VERSION="latest"
ARG RNP_VERSION="master"

ENV DEPS_BUILD_DIR="${HOME}/build"
WORKDIR /helpers/installers
RUN ./rvm.sh
RUN ./rnp.sh
RUN ./gpg.sh

# ---------------------------------------------------------------------------- #

FROM enmail-builder
USER testrunner
SHELL ["/bin/bash", "-l", "-c"]
ENV HOME="/home/testrunner"

###   ARGS   ###
ARG RUBY_VERSION="2.6"

ENV BUILD_DIR="${HOME}/enmail"

RUN mkdir -p ${BUILD_DIR}
COPY . ${BUILD_DIR}
WORKDIR ${BUILD_DIR}

RUN rvm use ${RUBY_VERSION} --install --fuzzy --ruby-version
RUN gem install bundler -v "~> 2.0"

#ENV BUNDLE_GEMFILE=$PWD/ci/Mail
RUN bundle install

# Generate OpenPGP test keys
RUN bundle exec rake pgp_keys:generate pgp_keys:list

CMD bundle exec rspec --format documentation --profile 200
