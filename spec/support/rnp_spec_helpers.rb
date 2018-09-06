# (c) Copyright 2018 Ribose Inc.
#

shared_context "rnp spec helpers" do
  # TODO This method is an exact copy of one from "gpgme spec helpers" context.
  # It was quite legitimate some time ago, but now is a good candidate for
  # refactoring.
  def decrypt_mail(message)
    gpg_runner = RSpec::PGPMatchers::GPGRunner
    encrypted_message = message.parts[1].body.decoded
    decrypted_raw_message, = gpg_runner.run_decrypt(encrypted_message)
    Mail::Part.new(decrypted_raw_message)
  end

  def adapter_class
    ::EnMail::Adapters::RNP
  end

  def default_expected_micalg
    "pgp-sha512"
  end
end
