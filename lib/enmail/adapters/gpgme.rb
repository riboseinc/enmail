require "gpgme"

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
        signer = find_signer_for(message)
        signature_part = build_signature_part(part_to_be_signed, signer)

        message.body = nil
        message.content_type = signed_part_content_type
        message.add_part part_to_be_signed
        message.add_part signature_part
      end

      def encrypt(message)
        part_to_be_encrypted = body_to_part(message)
        recipients = message.to_addrs
        encrypted_part = build_encrypted_part(part_to_be_encrypted, recipients)
        control_part = build_encryption_control_part

        message.body = nil
        message.content_type = encrypted_part_content_type
        message.add_part control_part
        message.add_part encrypted_part
      end

      # The RFC 3156 requires that the message is first signed, then encrypted.
      # See: https://tools.ietf.org/html/rfc3156#section-6.1
      def sign_and_encrypt_encapsulated(message)
        sign(message)
        encrypt(message)
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

      def build_signature_part(part_to_sign, signer)
        signature = compute_signature(part_to_sign.encoded, signer).to_s
        part = ::Mail::Part.new
        part.content_type = sign_protocol
        part.body = signature
        part
      end

      def build_encrypted_part(part_to_encrypt, recipients)
        encrypted = encrypt_string(part_to_encrypt.encoded, recipients).to_s
        part = ::Mail::Part.new
        part.content_type = "application/octet-stream"
        part.body = encrypted
        part
      end

      def build_encryption_control_part
        part = ::Mail::Part.new
        part.content_type = encryption_protocol
        part.body = "Version: 1" # As defined in RFC 3156
        part
      end

      def compute_signature(text, signer)
        build_crypto.detach_sign(text, signer: signer)
      end

      def encrypt_string(text, recipients)
        build_crypto.encrypt(text, recipients: recipients)
      end

      def find_signer_for(message)
        options[:signer] || message.from_addrs.first
      end

      def build_crypto
        ::GPGME::Crypto.new(armor: true)
      end

      public

      def signed_part_content_type
        protocol = sign_protocol
        micalg = message_integrity_algorithm
        %[multipart/signed; protocol="#{protocol}"; micalg="#{micalg}"]
      end

      def encrypted_part_content_type
        protocol = encryption_protocol
        %[multipart/encrypted; protocol="#{protocol}"]
      end

      def sign_protocol
        "application/pgp-signature"
      end

      def encryption_protocol
        "application/pgp-encrypted"
      end

      def message_integrity_algorithm
        "pgp-sha1"
      end
    end
  end
end
