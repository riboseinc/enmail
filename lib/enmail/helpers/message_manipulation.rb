module EnMail
  module Helpers
    # A toolbox with common operations for manipulating and reading message
    # properties, potentially useful for all adapters.
    module MessageManipulation
      protected

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

      # Detects a list of e-mails which should be used to define a list of
      # recipients of encrypted message.  All is simply taken from the message
      # +To:+ field.
      #
      # @param [Mail::Message] message
      # @return [Array] an array of e-mails
      def find_recipients_for(message)
        message.to_addrs
      end

      # Detects e-mail which should be used to find a message signer key.
      # Basically, it is taken from the message +From:+ field, but may be
      # overwritten by +:signer+ adapter option.
      #
      # @param [Mail::Message] message
      # @return [String] an e-mail
      def find_signer_for(message)
        options[:signer] || message.from_addrs.first
      end

      # Replaces a message body.  Clears all the existing body, be it multipart
      # or not, and then appends parts passed as an argument.
      #
      # @param [Mail::Message] message
      #   Message which body is expected to be replaced.
      # @param [String] content_type
      #   A new content type for message, required, must be kinda multipart.
      # @param [Array] parts
      #   List of parts which the new message body is expected to be composed
      #   from.
      # @return undefined
      def rewrite_body(message, content_type:, parts: [])
        message.body = nil
        message.content_type = content_type
        parts.each { |p| message.add_part(p) }
      end
    end
  end
end
