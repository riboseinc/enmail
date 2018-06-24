RSpec::Matchers.define :be_a_valid_pgp_signature_of do |text|
  attr_reader :err

  match do |signature_string|
    @err = parse_and_validate_signature(signature_string, text)
    @err.nil?
  end

  chain :signed_by, :expected_signer

  failure_message do
    err
  end

  # Returns +nil+ if first signature is valid, or an error message otherwise.
  def parse_and_validate_signature(signature_string, text)
    cleartext_data = GPGME::Data.new(text)
    signature_data = GPGME::Data.new(signature_string)

    GPGME::Ctx.new(armor: true) do |ctx|
      # That final +nil+ is obligatory
      ctx.verify(signature_data, cleartext_data, nil)
      match_signature(ctx.verify_result.signatures.first)
    end
  rescue GPGME::Error::NoData, GPGME::Error::General # Signature parse error
    msg_no_gpg_sig(signature_string)
  end

  def match_signature(sig)
    case
    when !sig.valid?
      msg_mismatch(text)
    when expected_signer && sig.key.email != expected_signer
      msg_wrong_signer(sig.key.email)
    else # rubocop:disable Style/EmptyElse - redundant but explicit
      nil
    end
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
