RSpec::Matchers.define :be_a_valid_pgp_signature_of do |text|
  match do |signature|
    @msg = nil
    begin
      ::GPGME::Crypto.new.verify(signature, signed_text: text) do |sig|
        @msg = msg_mismatch(text) unless sig.valid?
      end
    rescue GPGME::Error::NoData # Signature parse error
      @msg = msg_no_gpg_sig(signature)
    end
    @msg.nil?
  end

  failure_message do
    @msg
  end

  def msg_mismatch(text)
    "expected given signature to be a valid Open PGP signature " +
      "of following text:\n#{text}"
  end

  def msg_no_gpg_sig(sig_text)
    "expected given text to be a valid Open PGP signature, " +
      "but it contains no signature data, just:\n#{sig_text}"
  end
end
