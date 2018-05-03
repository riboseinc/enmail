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

      def compute_signature(text, signer)
        build_crypto.detach_sign(text, signer: signer)
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

      def sign_protocol
        "application/pgp-signature"
      end

      def message_integrity_algorithm
        "pgp-sha1"
      end
    end
  end
end
