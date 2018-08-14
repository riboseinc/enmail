# (c) Copyright 2018 Ribose Inc.
#

expected_gpg_version = ENV.fetch("EXPECT_GPG_VERSION", nil)

if expected_gpg_version
  gpg_version_info = ::GPGME::Engine.info.detect do |ei|
    %r"/bin/gpg\d*\Z" =~ ei.file_name
  end

  actual_gpg_version = gpg_version_info.version
  expected_gpg_version_rx = /\A#{Regexp.escape(expected_gpg_version)}(\.|\Z)/

  if expected_gpg_version_rx =~ actual_gpg_version
    puts "This test suite is run against GPG version #{actual_gpg_version}."
  else
    raise "This test suite was expected to run with GPG version " +
      "#{expected_gpg_version}, but was attempted to run with GPG version " +
      "#{actual_gpg_version}.  Aborting!"
  end
end
