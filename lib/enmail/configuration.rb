module EnMail
  class Configuration
    attr_reader :smime_adapter
    attr_accessor :sign_message, :certificates_path
    attr_accessor :sign_key, :encrypt_key

    def initialize
      @sign_message = true
      @smime_adapter = :openssl

      register_mail_intercepter
    end

    # Signable?
    #
    # Returns the message signing status, by defualt it will return `true`.
    # If the user provided a custom configuration for `sign_message` then
    # it will use that status, so we can easily skip it when desirable.
    #
    def signable?
      sign_message == true
    end

    # Set smime adapter
    #
    # This allows us to set a valid smime adapter, once this has been
    # set then the gem will use this on to select the correct adapter
    # class and then use that one to to `sign` a message.
    #
    # @param adapter adapter you want to use to sign the message
    #
    def smime_adapter=(adapter)
      if valid_smime_adapter?(adapter)
        @smime_adapter = adapter
      end
    end

    # Adapter klass name
    #
    # This returns the string class name for the configured smime
    # adapter. We are lazely loading the adapter so this interface
    # will return the string verion.  Please do not forget to use
    # `Object.const_get` before invokng any method on it.
    #
    def smime_adapter_klass
      smime_adapter_symbol_to_klass
    end

    # Default key
    #
    # This returns a Key instance with the configured keys.
    # @return [EnMail::Key] the configured default key attributes.
    #
    def default_key
      EnMail::Key.new(sign_key: sign_key, encrypt_key: encrypt_key)
    end

    # Register mail intercepter
    #
    # This method register `EnMail::Interceptor` as an intercepter to
    # the Mail class, so the mail class will pass the message before
    # delivering any email. `EnMail::Interceptor` will perform any of
    # the tasks based on the configuration and method invokation.
    #
    def register_mail_intercepter
      Mail.register_interceptor(EnMail::Interceptor)
    end

    private

    def valid_smime_adapter?(adapter)
      smime_adapters.include?(adapter.to_sym)
    end

    def smime_adapter_symbol_to_klass
      adapter_klasses.fetch(smime_adapter.to_sym)
    end

    # Supported smime adapters
    #
    # The list of the supported smime adapters, if we add support for
    # a new smime adapter then please update this list and this way we
    # can ensure user can configure the gem with supported adapter only
    #
    def smime_adapters
      [:openssl].freeze
    end

    def adapter_klasses
      { openssl: "EnMail::Adapters::OpenSSL" }
    end
  end
end
