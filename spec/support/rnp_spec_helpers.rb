shared_context "rnp spec helpers" do
  # This method is an exact copy of one from "gpgme spec helpers" context.
  # It's okay for now because both RNP and GPGME use the same homedir.
  # However it will become a problem when we start testing against different
  # software combinations, in which GPGME availability will not be guaranteed.
  #
  # TODO Make it using RNP
  def decrypt_mail(message)
    encrypted_message = message.parts[1].body.decoded
    decrypted_raw_message = GPGME::Crypto.new.decrypt(encrypted_message)
    Mail::Part.new(decrypted_raw_message)
  end

  def adapter_class
    ::EnMail::Adapters::RNP
  end
end
