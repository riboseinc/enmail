# (c) Copyright 2018 Ribose Inc.
#

begin
  require "gpgme"
rescue LoadError
end

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

      # TODO return actual digest algorithm name instead of pgp-sha1.
      def compute_signature(text, signer)
        signature = build_crypto.detach_sign(
          text,
          signer: signer,
          password: options[:key_password],
        )

        ["pgp-sha1", signature.to_s]
      end

      def encrypt_string(text, recipients)
        build_crypto.encrypt(text, recipients: recipients)
      end

      def sign_and_encrypt_string(text, signer, recipients)
        build_crypto.encrypt(
          text,
          sign: true,
          signers: [signer],
          recipients: recipients,
          password: options[:key_password],
        )
      end

      def build_crypto
        ::GPGME::Crypto.new(default_gpgme_options)
      end

      def default_gpgme_options
        {
          armor: true,
          pinentry_mode: ::GPGME::PINENTRY_MODE_LOOPBACK,
        }
      end
    end
  end
end
