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
    end
  end
end
