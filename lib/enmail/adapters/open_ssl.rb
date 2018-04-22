require "openssl"

module EnMail
  module Adapters
    class OpenSSL
      def initialize(key:, message:)
        @key = key
        @message = message
      end

      def sign
        write_smime(signed_data)
      end

      def self.sign(attributes)
        new(attributes).sign
      end

      private

      attr_reader :key, :message

      def write_smime(data)
        ::OpenSSL::PKCS7.write_smime(data)
      end

      def signed_data
        ::OpenSSL::PKCS7.sign(
          sender_certificate,
          sender_key,
          message.encoded,
          [],
          ::OpenSSL::PKCS7::DETACHED,
        )
      end

      def sender_key
        ::OpenSSL::PKey::RSA.new(key.sign_key, key.passphrase)
      end

      def sender_certificate
        ::OpenSSL::X509::Certificate.new(key.certificate)
      end
    end
  end
end
