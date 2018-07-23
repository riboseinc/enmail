shared_context "gpgme spec helpers" do
  def decrypt_mail(message)
    encrypted_message = message.parts[1].body.decoded
    decrypted_raw_message = GPGME::Crypto.new.decrypt(encrypted_message)
    Mail::Part.new(decrypted_raw_message)
  end

  def adapter_class
    ::EnMail::Adapters::GPGME
  end
end
