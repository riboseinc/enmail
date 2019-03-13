# (c) Copyright 2018 Ribose Inc.
#

unless ENV["TEST_WITHOUT_GPGME"]
  require "gpgme"
  GPGME::Engine.home_dir = TMP_PGP_HOME
end
