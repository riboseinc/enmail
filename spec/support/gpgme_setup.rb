# Keep tmp directory as short as possible.  UNIX has some annoying limit
# on file name length of the socket, and GPGME makes use of UNIX sockets.
# Directory name produced by +Dir.mktmpdir+ is often quite long, and that
# may cause weird error with misleading message.
tmp_gpgme_home = File.expand_path("../../tmp/gpgme", __dir__)
FileUtils.mkdir_p(tmp_gpgme_home)
GPGME::Engine.home_dir = tmp_gpgme_home
