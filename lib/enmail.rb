require "mail"
require "enmail/mail_ext/message"

require "enmail/signer"
require "enmail/interceptor"

module EnMail
  # Your code goes here...
end

# Register enmail interceptor
Mail.register_interceptor(EnMail::Interceptor)
