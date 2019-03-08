# (c) Copyright 2018 Ribose Inc.
#

shared_context "gpgme spec helpers" do
  def decrypt_mail(message)
    gpg_runner = RSpec::PGPMatchers::GPGRunner
    encrypted_message = message.parts[1].body.decoded
    decrypted_raw_message, = gpg_runner.run_decrypt(encrypted_message)
    Mail::Part.new(decrypted_raw_message)
  end

  def adapter_name
    :gpgme
  end

  # Actual preference is stored in gpg.conf, which is located in GnuPG home
  # (+tmp/pgp_home+), and created by Rake task.
  def default_expected_micalg
    "pgp-sha512"
  end
end
