module EnMail
  module EnMailable
    # Sign a message
    #
    # This interface allow us to sign a message while using this gem, this
    # also forecefully sets the `signable` status true, so it ensures that
    # the specific message will be signed before sending out.
    #
    # @param passphrase [String] the passphrase for the sign key
    # @param key [EnMail::Key] the key model instance
    #
    def sign(passphrase: "", key: nil)
      @key = key

      unless passphrase.empty?
        key.passphrase = passphrase
      end
    end

    # Key
    #
    # This returns the key instance when applicable, the default signing
    # key is configured through an initializer, but we are also allowing
    # user to provide a custom key when they are invoking an interface.
    #
    # @return [EnMail::Key] the key model instance
    #
    def key
      @key || EnMail.configuration.default_key
    end

    # Signing status
    #
    # This returns the message signing status based on the user specified
    # configuration and signing key. If the user enabled sign_message and
    # provided a valid signing key then this will return true otherwise
    # false, this can be used before trying to sing a message.
    #
    def signable?
      key.sign_key && EnMail.configuration.signable?
    end
  end
end
