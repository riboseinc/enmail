RSpec::Matchers.define :be_a_pgp_encrypted_message do
  attr_reader :err, :expected_recipients

  match do |encrypted_string|
    @err = validate_encrypted_message(encrypted_string)
    @err.nil?
  end

  chain :containing, :expected_cleartext

  chain :encrypted_for do |*recipients|
    @expected_recipients = [*recipients]
  end

  failure_message do
    err
  end

  # Returns +nil+ if signature is valid, or an error message otherwise.
  def validate_encrypted_message(encrypted)
    cleartext_data = GPGME::Data.new
    encrypted_data = GPGME::Data.new(encrypted)

    GPGME::Ctx.new do |ctx|
      ctx.decrypt_verify(encrypted_data, cleartext_data)
      cleartext = cleartext_data.to_s
      cipher_info = ctx.decrypt_result
      recipient_key_ids = cipher_info.recipients.map(&:keyid)
      recipients = recipient_key_ids.map { |kid| GPGME::Key.get(kid).email }
      match_cleartext_and_recipients(cleartext, recipients)
    end
  rescue GPGME::Error::NoData # Signature parse error
    msg_no_gpg_sig(encrypted)
  end

  def match_cleartext_and_recipients(cleartext, recipients)
    case
    when expected_cleartext && cleartext != expected_cleartext
      msg_mismatch(cleartext)
    when expected_recipients && expected_recipients.sort != recipients.sort
      msg_wrong_recipients(recipients)
    else # rubocop:disable Style/EmptyElse - redundant but explicit
      nil
    end
  end

  def msg_mismatch(text)
    "expected given Open PGP message to contain following " +
      "text:\n#{expected_cleartext}\nbut was:\n#{text}"
  end

  def msg_no_gpg_sig(sig_text)
    "expected given text to be a valid Open PGP signature, " +
      "but it contains no signature data, just:\n#{sig_text}"
  end

  def msg_wrong_recipients(recipients)
    expected_recipients_list = expected_recipients.inspect
    recipients_list = recipients.inspect

    "expected given Open PGP message to be encrypted for following " +
      "recipients: #{expected_recipients_list}, but was for: #{recipients_list}"
  end
end
