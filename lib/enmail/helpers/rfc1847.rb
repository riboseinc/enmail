module EnMail
  module Helpers
    # Common interface for building adapters conforming to RFC 1847 "Security
    # Multiparts for MIME: Multipart/Signed and Multipart/Encrypted".
    # It provides +sign+ and +encrypt+ public methods.
    module RFC1847
      protected

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
