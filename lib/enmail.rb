require "mail"

require "enmail/version"

require "enmail/adapters/gpgme"

module EnMail
  module_function

  def protect(mode, message, **options)
    adapter = Adapters::GPGME.new(options)
    adapter.public_send mode, message
  end
end
