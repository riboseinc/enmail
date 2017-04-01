require "enmail/adapters/open_ssl_signer"

module EnMail
  class Signer
    attr_reader :signed_data

    def initialize(key:, message:)
      @key = key
      @message = message
    end

    def sign
      sign_message || message
    end

    def self.sign(key:, message:)
      new(key: key, message: message).sign
    end

    private

    attr_reader :key, :message

    def sign_message
      @signed_data = signing_adapter.sign(key: key, message: message)
    end

    def signing_adapter
      EnMail::Adapters::OpenSSLSigner
    end
  end
end
