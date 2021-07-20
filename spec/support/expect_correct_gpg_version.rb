# (c) Copyright 2018 Ribose Inc.
#

expected_gpg_version = ENV.fetch("EXPECT_GPG_VERSION", nil)

if expected_gpg_version && ENV.fetch("TEST_WITHOUT_GPGME", nil).nil?
  require "gpgme"

  gpg_version_info = ::GPGME::Engine.info.detect do |ei|
    # GPG supports that protocol by definition, see:
    # https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG.html
    ei.protocol == ::GPGME::PROTOCOL_OpenPGP
  end

  actual_gpg_version = gpg_version_info.version
  expected_gpg_version_rx = /\A#{Regexp.escape(expected_gpg_version)}(\.|\Z)/

  if expected_gpg_version_rx&.match?(actual_gpg_version)
    puts "This test suite is run against GPG version #{actual_gpg_version}."
  else
    raise(
      "This test suite was expected to run with GPG version" \
      " #{expected_gpg_version}, but was attempted to run with GPG version" \
      " #{actual_gpg_version}.  Aborting!"
    )
  end
end
