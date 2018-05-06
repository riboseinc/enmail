module EnMail
  module Helpers
    # Common interface for building adapters conforming to RFC 1847 "Security
    # Multiparts for MIME: Multipart/Signed and Multipart/Encrypted".
    # It provides +sign+ and +encrypt+ public methods.
    module RFC1847
      include MessageManipulation

      # Signs a message in a +multipart/signed+ fashion as defined in RFC 1847.
      #
      # @param [Mail::Message] message
      #   Message which is expected to be signed.
      def sign(message)
        part_to_be_signed = body_to_part(message)
        signer = find_signer_for(message)
        signature_part = build_signature_part(part_to_be_signed, signer)

        rewrite_body(
          message,
          content_type: multipart_signed_content_type,
          parts: [part_to_be_signed, signature_part],
        )
      end

      # Encrypts a message in a +multipart/encrypted+ fashion as defined
      # in RFC 1847.
      #
      # @param [Mail::Message] message
      #   Message which is expected to be encrypted.
      def encrypt(message)
        part_to_be_encrypted = body_to_part(message)
        recipients = find_recipients_for(message)
        encrypted_part = build_encrypted_part(part_to_be_encrypted, recipients)
        control_part = build_encryption_control_part

        rewrite_body(
          message,
          content_type: multipart_encrypted_content_type,
          parts: [control_part, encrypted_part],
        )
      end

      protected

      # Builds a mail part containing the encrypted message, that is
      # the 2nd subpart of +multipart/encrypted+ as defined in RFC 1847.
      def build_encrypted_part(part_to_encrypt, recipients)
        encrypted = encrypt_string(part_to_encrypt.encoded, recipients).to_s
        part = ::Mail::Part.new
        part.content_type = encrypted_message_content_type
        part.body = encrypted
        part
      end

      # Builds a mail part containing the control information for encrypted
      # message, that is the 1st subpart of +multipart/encrypted+ as defined in
      # RFC 1847.
      def build_encryption_control_part
        part = ::Mail::Part.new
        part.content_type = encryption_protocol
        part.body = encryption_control_information
        part
      end

      # Builds a mail part containing the digital signature, that is
      # the 2nd subpart of +multipart/signed+ as defined in RFC 1847.
      def build_signature_part(part_to_sign, signer)
        signature = compute_signature(part_to_sign.encoded, signer).to_s
        part = ::Mail::Part.new
        part.content_type = sign_protocol
        part.body = signature
        part
      end

      def multipart_signed_content_type
        protocol = sign_protocol
        micalg = message_integrity_algorithm
        %[multipart/signed; protocol="#{protocol}"; micalg="#{micalg}"]
      end

      def multipart_encrypted_content_type
        protocol = encryption_protocol
        %[multipart/encrypted; protocol="#{protocol}"]
      end

      # The encrypted message must have content type +application/octet-stream+,
      # as defined in RFC 1847 p. 6.
      def encrypted_message_content_type
        "application/octet-stream"
      end
    end
  end
end
