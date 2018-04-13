module EnMail
  module Adapters
    # Secures e-mails according to {RFC 3156 "MIME Security with OpenPGP"}[
    # https://tools.ietf.org/html/rfc3156].
    #
    # This adapter uses {GnuPG Made Easy (GPGME)}[
    # https://www.gnupg.org/software/gpgme/index.html] library via interface
    # provided by {gpgme gem}[https://github.com/ueno/ruby-gpgme].
    class GPGME
      attr_reader :options

      def initialize(options)
        @options = options
      end

      # TODO Sign
      # TODO Handle multi-part messages
      # TODO Copy MIME headers to signed part (ones which start with "Content-")
      # TODO Ensure correct Content-Transfer-Encoding (as defined in RFC)
      # TODO Preserve Content-Transfer-Encoding when possible
      def sign(message); end
    end
  end
end
