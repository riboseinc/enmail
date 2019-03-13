# (c) Copyright 2018 Ribose Inc.
#

unless ENV["TEST_WITHOUT_RNP"]
  require "rnp"

  def Rnp.default_homedir
    TMP_PGP_HOME
  end
end
