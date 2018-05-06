require "gpgme"

module EnMail
  module Adapters
    # Secures e-mails according to {RFC 3156 "MIME Security with OpenPGP"}[
    # https://tools.ietf.org/html/rfc3156].
    #
    # This adapter uses {GnuPG Made Easy (GPGME)}[
    # https://www.gnupg.org/software/gpgme/index.html] library via interface
    # provided by {gpgme gem}[https://github.com/ueno/ruby-gpgme].
    class GPGME < Base
      include Helpers::MessageManipulation
      include Helpers::RFC1847
      include Helpers::RFC3156

      private

      def compute_signature(text, signer)
        build_crypto.detach_sign(text, signer: signer)
      end

      def encrypt_string(text, recipients)
        build_crypto.encrypt(text, recipients: recipients)
      end

      def build_crypto
        ::GPGME::Crypto.new(armor: true)
      end
    end
  end
end
