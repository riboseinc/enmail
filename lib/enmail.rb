# (c) Copyright 2018 Ribose Inc.
#

require "mail"

require "enmail/version"
require "enmail/dependency_constraints"

require "enmail/helpers/message_manipulation"
require "enmail/helpers/rfc1847"
require "enmail/helpers/rfc3156"

require "enmail/adapters/base"
require "enmail/adapters/gpgme"
require "enmail/adapters/rnp"

require "enmail/extensions/message_transport_encoding_restrictions"

module EnMail
  module_function

  def protect(mode, message, adapter:, **options)
    adapter_class = Adapters::Base.resolve_adapter_name(adapter)
    adapter_obj = adapter_class.new(options)
    adapter_obj.public_send mode, message
  end
end

Mail::Message.prepend EnMail::Extensions::MessageTransportEncodingRestrictions
