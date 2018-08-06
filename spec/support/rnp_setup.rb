# Keep tmp directory as short as possible.  UNIX has some annoying limit
# on file name length of the socket, and GPGME makes use of UNIX sockets.
# Directory name produced by +Dir.mktmpdir+ is often quite long, and that
# may cause weird error with misleading message.
TMP_RNP_HOME = File.expand_path("../../tmp/pgp_home", __dir__)
FileUtils.mkdir_p(TMP_RNP_HOME)

def Rnp.default_homedir
  TMP_RNP_HOME
end
