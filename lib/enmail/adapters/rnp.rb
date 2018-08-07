require "rnp"

module EnMail
  module Adapters
    # Secures e-mails according to {RFC 3156 "MIME Security with OpenPGP"}[
    # https://tools.ietf.org/html/rfc3156].
    #
    # This adapter uses {RNP}[https://github.com/riboseinc/rnp] library via
    # {ruby-rnp gem}[https://github.com/riboseinc/ruby-rnp].
    #
    # NOTE: `Rnp` instances are not thread-safe, and neither this adapter is.
    # Any adapter instance should be accessed by at most one thread at a time.
    class RNP < Base
      include Helpers::MessageManipulation
      include Helpers::RFC1847
      include Helpers::RFC3156

      attr_reader :rnp

      def initialize(*args)
        super
        @rnp = build_rnp_and_load_keys
      end

      private

      def compute_signature(text, signer)
        signer_key = find_key_for(signer, need_secret: true)

        rnp.detached_sign(
          signers: [signer_key],
          input: build_input(text),
          armored: true,
        )
      end

      def encrypt_string(text, recipients)
        recipient_keys =
          recipients.map { |r| find_key_for(r, need_public: true) }

        rnp.encrypt(
          recipients: recipient_keys,
          input: build_input(text),
          armored: true,
        )
      end

      def sign_and_encrypt_string(text, signer, recipients)
        signer_key = find_key_for(signer, need_secret: true)
        recipient_keys =
          recipients.map { |r| find_key_for(r, need_public: true) }

        rnp.encrypt_and_sign(
          recipients: recipient_keys,
          signers: signer_key,
          input: build_input(text),
          armored: true,
        )
      end

      def find_key_for(email, need_public: false, need_secret: false)
        rnp.each_keyid do |keyid|
          key = rnp.find_key(keyid: keyid)
          next if need_public && !key.public_key_present?
          next if need_secret && !key.secret_key_present?

          key.each_userid do |userid|
            return key if userid.include?(email)
          end
        end
        nil
      end

      def build_input(text)
        ::Rnp::Input.from_string(text)
      end

      def build_rnp_and_load_keys
        homedir = options[:homedir] || Rnp.default_homedir
        homedir_info = ::Rnp.homedir_info(homedir)
        public_info, secret_info = homedir_info.values_at(:public, :secret)

        rnp = Rnp.new(public_info[:format], secret_info[:format])

        [public_info, secret_info].each do |keyring_info|
          input = ::Rnp::Input.from_path(keyring_info[:path])
          rnp.load_keys(format: keyring_info[:format], input: input)
        end

        rnp.password_provider = options[:key_password]

        rnp
      end
    end
  end
end
