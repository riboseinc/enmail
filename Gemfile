# (c) Copyright 2018 Ribose Inc.
#

source "https://rubygems.org"

# Specify your gem's dependencies in enmail.gemspec
gemspec

gem "codecov", require: false, group: :test
gem "simplecov", require: false, group: :test

gem "gpgme" unless ENV["TEST_WITHOUT_GPGME"]
gem "rnp", ">= 1.0.1", "< 2" unless ENV["TEST_WITHOUT_RNP"]
