# A following PGP matcher calls the GPG executable in a subshell, then
# parses command output.  This is a poor pattern in general, because output
# messages may subtly change over GPG evolution, and some maintenance work
# may be required.
#
# However, GPG executables do not provide any machine-readable output which
# could be used instead.  Furthermore, using RNP or GPGME from here is also
# a poor idea, because this gem is going to be tested against various
# combinations of software, in some of which that dependency may be unavailable.
#
# If parsing the output of GPG commands will become a burden, then the preferred
# solution is to develop a minimalist validator which, if executed in
# a subshell, returns some useful machine-readable output.  A validator tool
# running in a separate process may leverage GPGME, as it won't be exposed
# outside the validator.  A previous implementation of this matcher may provide
# some useful ideas.  See commit 2e2bd0da090d7d31ecacc2d1ea6bd3e13479e675.
RSpec::Matchers.define :be_a_pgp_encrypted_message do
  include GpgMatcherHelper

  attr_reader :err, :expected_recipients

  match do |encrypted_string|
    @err = validate_encrypted_message(encrypted_string)
    @err.nil?
  end

  chain :containing, :expected_cleartext
  chain :signed_by, :expected_signer

  chain :encrypted_for do |*recipients|
    @expected_recipients = [*recipients]
  end

  failure_message do
    err
  end

  # Returns +nil+ if signature is valid, or an error message otherwise.
  def validate_encrypted_message(encrypted_string)
    cmd_output = run_gpg_decrypt(encrypted_string)
    cmd_result = analyse_decrypt_output(*cmd_output)

    if cmd_result[:well_formed_pgp_data]
      match_constraints(**cmd_result)
    else
      msg_no_pgg_data(encrypted_string)
    end
  end

  def run_gpg_decrypt(encrypted_string)
    enc_file = make_tempfile_containing(encrypted_string)
    cmd = gpg_decrypt_command(enc_file)
    run_command(cmd)
  end

  def analyse_decrypt_output(stdout_str, stderr_str, status)
    {
      well_formed_pgp_data: (status.exitstatus != 2),
      recipients: detect_recipients(stderr_str),
      signature: detect_signers(stderr_str).first,
      cleartext: stdout_str,
    }
  end

  def match_constraints(cleartext:, recipients:, signature:, **_ignored)
    [
      (expected_cleartext && match_cleartext(cleartext)),
      (expected_recipients && match_recipients(recipients)),
      (expected_signer && match_signature(signature)),
    ].detect { |x| x }
  end

  def gpg_decrypt_command(enc_file)
    homedir_path = Shellwords.escape(TMP_GPGME_HOME)
    enc_path = Shellwords.escape(enc_file.path)

    <<~SH
      gpg \
      --homedir #{homedir_path} \
      --no-permission-warning \
      --decrypt #{enc_path}
    SH
  end

  def msg_mismatch(text)
    "expected given Open PGP message to contain following " +
      "text:\n#{expected_cleartext}\nbut was:\n#{text}"
  end

  def msg_no_pgg_data(file_text)
    "expected given text to be a valid Open PGP encrypted message, " +
      "but it contains no PGP data, just:\n#{file_text}"
  end

  def msg_wrong_recipients(recipients)
    expected_recipients_list = expected_recipients.inspect
    recipients_list = recipients.inspect

    "expected given Open PGP message to be encrypted for following " +
      "recipients: #{expected_recipients_list}, but was for: #{recipients_list}"
  end

  def msg_wrong_signer(actual_signer)
    "expected singature to be signed by #{expected_signer}, " +
      "but was actually signed by #{actual_signer}"
  end
end
