require "mail"

require "enmail/version"

require "enmail/helpers/message_manipulation"
require "enmail/helpers/rfc1847"
require "enmail/helpers/rfc3156"

require "enmail/adapters/base"
require "enmail/adapters/gpgme"

module EnMail
  module_function

  def protect(mode, message, **options)
    adapter = Adapters::GPGME.new(options)
    adapter.public_send mode, message
  end
end
