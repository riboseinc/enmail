# (c) Copyright 2018 Ribose Inc.
#

module EnMail
  module Adapters
    class Base
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def self.resolve_adapter_name(adapter_name)
        case adapter_name
        when Class
          adapter_name
        when :rnp, :gpgme, "rnp", "gpgme"
          EnMail::Adapters.const_get(adapter_name.to_s.upcase)
        else
          raise ArgumentError, "Unknown EnMail adapter: #{adapter_name.inspect}"
        end
      end
    end
  end
end
