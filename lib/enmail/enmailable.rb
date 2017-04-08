module EnMail
  module EnMailable
    # Sign a message
    #
    # This interface allow us to sign a message while using this gem, this
    # also forecefully sets the `signable` status true, so it ensures that
    # the specific message will be signed before sending out.
    #
    # @param passphrase passphrase to use the private key.
    #
    def sign(passphrase = "")
      @signable = true
      @passphrase = passphrase
    end

    # Signing status
    #
    # This returns the message signing status based on the user specified
    # configuration, by default it uses the default configuration.It will
    # be overridden when we set the `signable` status on this instance.
    #
    def signable?
      @signable || EnMail.configuration.signable?
    end

    private

    attr_reader :signable, :passphrase
  end
end
