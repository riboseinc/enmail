module EnMail
  module Helpers
    # Common interface for building adapters conforming to RFC 3156 "MIME
    # Security with OpenPGP", which is an implementation of RFC 1847
    # "Security Multiparts for MIME: Multipart/Signed and Multipart/Encrypted".
    #
    # See: https://tools.ietf.org/html/rfc3156
    module RFC3156
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
