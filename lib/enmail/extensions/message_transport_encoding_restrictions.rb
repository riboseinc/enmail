module EnMail
  module Extensions
    module MessageTransportEncodingRestrictions
      def identify_and_set_transfer_encoding
        if @enmail_rfc18467_encoding_restrictions && !multipart?
          str = body.raw_source
          self.content_transfer_encoding = [
            ::Mail::Encodings::Base64,
            ::Mail::Encodings::QuotedPrintable,
          ].min { |a, b| a.cost(str) <=> b.cost(str) }
        else
          super
        end
      end
    end
  end
end
