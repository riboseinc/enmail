module MailInterceptors
  class PGP

    def self.delivering_email(mail)

      return unless mail.gpg

      options = TrueClass === mail.gpg ? { encrypt: true } : mail.gpg
      # encrypt and sign are off -> do not encrypt or sign
      if options.delete(:encrypt)
        receivers = []
        receivers += mail.to if mail.to
        receivers += mail.cc if mail.cc
        receivers += mail.bcc if mail.bcc

        if options[:sign_as]
          options[:sign] = true
          options[:signers] = options.delete(:sign_as)
        elsif options[:sign]
          options[:signers] = mail.from
        end

        # Need to remove any non-SignedPart & non-SignPart
        mail.body = ''

        mail.add_part Mail::Gpg::VersionPart.new
        mail.add_part Mail::Gpg::EncryptedPart.new(mail, options.merge({recipients: receivers}))
        mail.content_type "multipart/encrypted; protocol=\"application/pgp-encrypted\"; boundary=#{mail.boundary}"
        mail.body.preamble = options[:preamble] || "This is an OpenPGP/MIME encrypted message (RFC 2440 and 3156)"

      elsif options[:sign] || options[:sign_as]

        to_be_signed = Mail::Gpg::SignedPart.build(mail)

        # Need to remove any non-SignedPart & non-SignPart
        mail.body = ''

        mail.add_part to_be_signed
        mail.add_part to_be_signed.sign(options)

        mail.content_type "multipart/signed; micalg=pgp-sha1; protocol=\"application/pgp-signature\"; boundary=#{mail.boundary}"
        mail.body.preamble = options[:preamble] || "This is an OpenPGP/MIME signed message (RFC 4880 and 3156)"
      end

      puts "pee pee mail@"
      pp mail

    rescue Exception
      raise $! if mail.raise_encryption_errors
    end

  end
end
