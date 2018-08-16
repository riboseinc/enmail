# (c) Copyright 2018 Ribose Inc.
#

if defined?(::GPGME)
  GPGME::Engine.home_dir = TMP_PGP_HOME
end
