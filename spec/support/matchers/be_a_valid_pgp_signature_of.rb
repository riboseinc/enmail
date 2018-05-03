RSpec::Matchers.define :be_a_valid_pgp_signature_of do |text|
  match do |signature|
    @msg = validate_signature(signature, text)
    @msg.nil?
  end

  chain :signed_by, :expected_signer

  failure_message do
    @msg
  end

  # Returns +nil+ if signature is valid, or an error message otherwise.
  def validate_signature(signature, text)
    ::GPGME::Crypto.new.verify(signature, signed_text: text) do |sig|
      case
      when !sig.valid?
        return msg_mismatch(text)
      when expected_signer && sig.key.email != expected_signer
        return msg_wrong_signer(sig.key.email)
      end
    end
    nil
  rescue GPGME::Error::NoData # Signature parse error
    msg_no_gpg_sig(signature)
  end

  def msg_mismatch(text)
    "expected given signature to be a valid Open PGP signature " +
      "of following text:\n#{text}"
  end

  def msg_no_gpg_sig(sig_text)
    "expected given text to be a valid Open PGP signature, " +
      "but it contains no signature data, just:\n#{sig_text}"
  end

  def msg_wrong_signer(actual_signer)
    "expected singature to be signed by #{expected_signer}, " +
      "but was actually signed by #{actual_signer}"
  end
end
