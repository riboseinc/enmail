require "enmail/adapters/open_ssl"

module EnMail
  class Encrypter
    def initialize(message:, key:)
      @key = key
      @message = message
    end

    def sign
      sign_message
    end

    def self.sign(message)
      new(message: message, key: message.key).sign
    end

    private

    attr_reader :key, :message

    def sign_message
      smime_adapter.sign(key: key, message: message)
    end

    # Selected adapter
    #
    # Ideally, this where we will grap the adapter form the user
    # specified configurations, for now let's keep it simple and
    # use the openssl as default for now.
    #
    def smime_adapter
      @smime_adapter ||= Object.const_get(
        EnMail.configuration.smime_adapter_klass
      )
    end
  end
end
