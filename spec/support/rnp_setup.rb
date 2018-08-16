# (c) Copyright 2018 Ribose Inc.
#

if defined?(::Rnp)
  def Rnp.default_homedir
    TMP_PGP_HOME
  end
end
