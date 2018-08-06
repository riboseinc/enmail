module EnMail
  module Helpers
    # Common interface for building adapters conforming to RFC 3156 "MIME
    # Security with OpenPGP", which is an implementation of RFC 1847
    # "Security Multiparts for MIME: Multipart/Signed and Multipart/Encrypted".
    #
    # See: https://tools.ietf.org/html/rfc3156
    module RFC3156
      include RFC1847

      # The RFC 3156 explicitly allows for signing and encrypting data in
      # a single OpenPGP message.
      # See: https://tools.ietf.org/html/rfc3156#section-6.2
      #
      # rubocop:disable Metrics/MethodLength
      def sign_and_encrypt_combined(message)
        source_part = body_to_part(message)
        restrict_encoding(source_part)
        signer = find_signer_for(message)
        recipients = find_recipients_for(message)
        encrypted =
          sign_and_encrypt_string(source_part.encoded, signer, recipients).to_s
        encrypted_part = build_encrypted_part(encrypted)
        control_part = build_encryption_control_part

        rewrite_body(
          message,
          content_type: multipart_encrypted_content_type,
          parts: [control_part, encrypted_part],
        )
      end
      # rubocop:enable Metrics/MethodLength

      # The RFC 3156 requires that the message is first signed, then encrypted.
      # See: https://tools.ietf.org/html/rfc3156#section-6.1
      def sign_and_encrypt_encapsulated(message)
        sign(message)
        encrypt(message)
      end

      protected

      def sign_protocol
        "application/pgp-signature"
      end

      def encryption_protocol
        "application/pgp-encrypted"
      end

      def message_integrity_algorithm
        "pgp-sha1"
      end

      # As defined in RFC 3156
      def encryption_control_information
        "Version: 1"
      end
    end
  end
end
