require "enmail/signer"

module EnMail
  class Interceptor
    attr_reader :message

    def initialize(message)
      @message = message
    end

    def intercept
      EnMail::Signer.sign(message)
    end

    def self.delivering_email(message)
      new(message).intercept
    end
  end
end
