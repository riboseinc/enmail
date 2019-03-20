# (c) Copyright 2018 Ribose Inc.
#

require "zeitwerk"

loader_inflector = Zeitwerk::Inflector.new

def loader_inflector.camelize(basename, _abspath)
  case basename
  when "enmail" then "EnMail"
  when "rnp", "gpgme", /^rfc\d/ then basename.upcase
  else super
  end
end

loader = Zeitwerk::Loader.for_gem
loader.inflector = loader_inflector
# Ignore files which serve for loading optional dependencies.
loader.ignore("#{__dir__}/enmail/adapters/*_requirements.rb")
loader.setup # ready!

require "mail"

module EnMail
  module_function

  def protect(mode, message, adapter:, **options)
    adapter_obj = adapter.new(options)
    adapter_obj.public_send mode, message
  end
end

Mail::Message.prepend EnMail::Extensions::MessageTransportEncodingRestrictions
