# (c) Copyright 2018 Ribose Inc.
#

module EnMail
  module Adapters
    # Secures e-mails according to {RFC 3156 "MIME Security with
    # OpenPGP"}[https://tools.ietf.org/html/rfc3156].
    #
    # This adapter uses {GnuPG Made Easy
    # (GPGME)}[https://www.gnupg.org/software/gpgme/index.html] library via
    # interface provided by {gpgme gem}[https://github.com/ueno/ruby-gpgme].
    class GPGME < Base
      include Helpers::MessageManipulation
      include Helpers::RFC1847
      include Helpers::RFC3156

      def initialize(*args)
        require_relative "gpgme_requirements"
        super
      end

      private

      def compute_signature(text, signer)
        plain = ::GPGME::Data.new(text)
        output = ::GPGME::Data.new
        mode = ::GPGME::SIG_MODE_DETACH
        hash_algorithm = nil

        with_ctx(password: options[:key_password]) do |ctx|
          signer_keys = ::GPGME::Key.find(:secret, signer, :sign)
          ctx.add_signer(*signer_keys)

          begin
            ctx.sign(plain, output, mode)
            hash_algorithm_num = ctx.sign_result.signatures[0].hash_algo
            hash_algorithm = ::GPGME.hash_algo_name(hash_algorithm_num)
          rescue ::GPGME::Error::UnusableSecretKey => e
            # TODO Copy-pasted from GPGME gem.  Needs any test coverage.
            e.keys = ctx.sign_result.invalid_signers
            raise e
          end
        end

        output.seek(0)

        ["pgp-#{hash_algorithm.downcase}", output.to_s]
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

      def with_ctx(options, &block)
        ctx_options = default_gpgme_options.merge(options)
        ::GPGME::Ctx.new(ctx_options, &block)
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
