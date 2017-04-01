module EnMail
  module Adapters
    class OpenSSLSigner
      def self.sign(key:, message:)
        [message, "Signed by -", key].join(" ")
      end
    end
  end
end
