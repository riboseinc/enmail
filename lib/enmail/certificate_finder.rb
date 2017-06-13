require "openssl"

module EnMail
  class CertificateFinder
    def initialize(email:)
      @email = email
    end

    # Certificate
    #
    # This returns an `OpenSSL::X509::Certificate` instnace which
    # usages the content for the pem certificate. The certificate
    # name is the dotify version of the email with `pem` ext.
    #
    def certificate
      certificate_instance
    end

    # Private Key
    #
    # This returns an `OpenSSL::PKey::RSA` instnace which usages
    # the content for keyfile. The keyfile is the dotify version
    # of the email with `key` ext.
    #
    def private_key
      private_key_instance
    end

    # Self.find_by_email
    #
    # Initialize a new instnace with more readble interface.
    #
    def self.find_by_email(email)
      new(email: email)
    end

    private

    attr_reader :email

    def certificate_instance
      OpenSSL::X509::Certificate.new(
        certificate_file(extension: :pem),
      )
    end

    def private_key_instance
      OpenSSL::PKey::RSA.new(
        certificate_file(extension: :key),
      )
    end

    def certificate_file(extension:)
      content_for(
        [dotify_email, extension.to_s].join("."),
      )
    end

    def dotify_email
      @dotify_email ||= email.sub("@", ".")
    end

    def content_for(filename)
      File.read(certificate_file_with_path(filename))
    end

    def certificate_file_with_path(certificate)
      File.join(certificates_root, certificate)
    end

    def certificates_root
      EnMail.configuration.certificates_path
    end
  end
end
