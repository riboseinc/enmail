module EnMail
  class Configuration
    attr_accessor :sign_message
    attr_accessor :certificates_path

    def initialize
      @sign_message = true
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
  end
end
