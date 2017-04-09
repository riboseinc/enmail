module EnMail
  class Key
    # @!attribute [r] sign_key
    #   @return [String] the signing key content
    #
    attr_reader :sign_key

    # @!attribute passphrase
    #   @return [String] the signing key passphrase
    #
    attr_reader :passphrase

    # @!attribute [r] encrypt_key
    #   @return [String] the encryping key content
    #
    attr_reader :encrypt_key

    # @!attribute [r] certificate
    #   @return [String] the certificate content
    #
    attr_reader :certificate

    # Initialize a key model with the basic attributes, this expects us
    # to provided the key/certificate as string and when we actually use
    # it then the configured adapter will use it as necessary.
    #
    # @param :sign_key [String] the signing key content
    # @param :passphrase [String] the passphrase for encrypted key
    # @param :encrypt_key [String] the encryping key content
    # @param :certificate [String] the signing certificate content
    #
    # @return [EnMail::Key] - the EnMail::Key model
    #
    def initialize(attributes)
      @sign_key = attributes.fetch(:sign_key, "")
      @passphrase = attributes.fetch(:passphrase, "")
      @encrypt_key = attributes.fetch(:encrypt_key, "")
      @certificate = attributes.fetch(:certificate, "")
    end

    # Set the passphrase value
    #
    # This allow us to set the passphrase after initialization, so if the
    # user prefere then they can pass the passphrase during the siging /
    # encrypting steps and we can set that one when necessary
    #
    # @param passphrase [String] the passphrase for encrypted key
    #
    def passphrase=(passphrase)
      @passphrase = passphrase
    end
  end
end
