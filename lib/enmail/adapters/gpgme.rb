module EnMail
  module Adapters
    # Secures e-mails according to {RFC 3156 "MIME Security with OpenPGP"}[
    # https://tools.ietf.org/html/rfc3156].
    #
    # This adapter uses {GnuPG Made Easy (GPGME)}[
    # https://www.gnupg.org/software/gpgme/index.html] library via interface
    # provided by {gpgme gem}[https://github.com/ueno/ruby-gpgme].
    class GPGME
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def sign(message)
        part_to_be_signed = body_to_part(message)
        signature_part = build_signature_part(part_to_be_signed)

        message.body = nil
        message.content_type = signed_part_content_type
        message.add_part part_to_be_signed
        message.add_part signature_part
      end

      private

      # Returns a new +Mail::Part+ with the same content and MIME headers
      # as the message passed as an argument.
      #
      # Although Mail gem provides +Mail::Message#convert_to_multipart+ method,
      # it works correctly for non-multipart text/plain messages only.  This
      # method is more robust, and handles messages containing any content type,
      # be they multipart or not.
      #
      # The message passed as an argument is not altered.
      #
      # TODO Copy MIME headers (ones which start with "Content-")
      # TODO Preserve Content-Transfer-Encoding when possible
      # TODO Set some safe Content-Transfer-Encoding, like quoted-printable
      def body_to_part(message)
        part = ::Mail::Part.new
        part.content_type = message.content_type
        if message.multipart?
          message.body.parts.each { |p| part.add_part p.dup }
        else
          part.body = message.body.decoded
        end
        part
      end

      def build_signature_part(_part_to_sign)
        signature = "DUMMY_SIGNATURE"
        part = ::Mail::Part.new
        part.content_type = sign_protocol
        part.body = signature
        part
      end

      public

      def signed_part_content_type
        "multipart/signed"
      end

      def sign_protocol
        "application/pgp-signature"
      end
    end
  end
end