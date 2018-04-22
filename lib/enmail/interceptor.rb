require "enmail/encrypter"

module EnMail
  class Interceptor
    def initialize(message)
      @message = message
    end

    def intercept
      overwrite_message(
        sign_message(message),
      )
    end

    def self.delivering_email(message)
      new(message).intercept
    end

    private

    attr_reader :message

    def overwrite_message(message_body)
      # We will also deal with content type here
      #
      message.body = message_body
    end

    def sign_message(message)
      signed_message(message) || message
    end

    def signed_message(message)
      if signable_message?
        EnMail::Encrypter.sign(message)
      end
    end

    def signable_message?
      message.signable?
    end
  end
end
