module Mail
  class Message
    attr_reader :signer

    def sign(signer)
      @signer = signer
    end
  end
end
