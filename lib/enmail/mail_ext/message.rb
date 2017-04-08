require "mail"
require "enmail/enmailable"

module Mail
  class Message
    # Include enmail interfaces
    #
    # We are supporting some custom interfaces for the mail instance,
    # so the user can use `sign`, `encrypt` and `decrypt` directly to
    # their mail instance.
    #
    # The `EnMail::EnMailable` module defines all of the interfaces
    # to support the above funcitonality, so let's include that and
    # please check `EnMail::EnMailable` for more details on those.
    #
    include EnMail::EnMailable
  end
end
