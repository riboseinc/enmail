# (c) Copyright 2018 Ribose Inc.
#

shared_context "gpgme spec helpers" do
  def decrypt_mail(message)
    gpg_runner = RSpec::PGPMatchers::GPGRunner
    encrypted_message = message.parts[1].body.decoded
    decrypted_raw_message, = gpg_runner.run_decrypt(encrypted_message)
    Mail::Part.new(decrypted_raw_message)
  end

  def adapter_class
    ::EnMail::Adapters::GPGME
  end

  def default_expected_micalg
    "pgp-sha1"
  end
end
