# (c) Copyright 2018 Ribose Inc.
#

source "https://rubygems.org"

# Specify your gem's dependencies in enmail.gemspec
gemspec

gem "codecov", require: false, group: :test
gem "simplecov", require: false, group: :test

gem "gpgme", install_if: -> { !ENV["TEST_WITHOUT_GPGME"] }
gem "rnp", install_if: -> { !ENV["TEST_WITHOUT_RNP"] }
