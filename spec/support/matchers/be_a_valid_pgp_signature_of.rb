# (c) Copyright 2018 Ribose Inc.
#

# A following PGP matcher calls the GPG executable in a subshell, then
# parses command output.  This is a poor pattern in general, because output
# messages may subtly change over GPG evolution.
#
# However, GPG executables do not provide any machine-readable output which
# could be used instead.  Furthermore, using RNP or GPGME from here is also
# a poor idea, because this gem is going to be tested against various
# combinations of software, in some of which that dependency may be unavailable.
#
# If output parsing will ever become a source of problems, then the preferred
# solution is to develop a minimalist validator which, if executed in
# a subshell, returns useful machine-readable output.  A validator tool running
# in a separate process may leverage GPGME, as it won't be exposed outside
# the validator.  A previous implementation of this matcher may provide some
# useful ideas.  See commit 2e2bd0da090d7d31ecacc2d1ea6bd3e13479e675.
RSpec::Matchers.define :be_a_valid_pgp_signature_of do |text|
  include GpgMatcherHelper

  attr_reader :err

  match do |signature_string|
    @err = verify_signature(text, signature_string)
    @err.nil?
  end

  chain :signed_by, :expected_signer

  failure_message do
    err
  end

  # Returns +nil+ if first signature is valid, or an error message otherwise.
  def verify_signature(cleartext, signature_string)
    cmd_output = run_gpg_verify(cleartext, signature_string)
    cmd_result = analyse_verify_output(*cmd_output)

    if cmd_result[:well_formed_pgp_data]
      match_constraints(**cmd_result)
    else
      msg_no_pgg_data(signature_string)
    end
  end

  def run_gpg_verify(cleartext, signature_string)
    sig_file = make_tempfile_containing(signature_string)
    data_file = make_tempfile_containing(cleartext)
    cmd = gpg_verify_command(sig_file, data_file)
    run_command(cmd)
  end

  def analyse_verify_output(_stdout_str, stderr_str, status)
    {
      well_formed_pgp_data: (status.exitstatus != 2),
      signature: detect_signers(stderr_str).first,
    }
  end

  def match_constraints(signature:, **_ignored)
    match_signature(signature)
  end

  def gpg_verify_command(sig_file, data_file)
    homedir_path = Shellwords.escape(TMP_PGP_HOME)
    sig_path = Shellwords.escape(sig_file.path)
    data_path = Shellwords.escape(data_file.path)

    <<~SH
      gpg \
      --homedir #{homedir_path} \
      --no-permission-warning \
      --verify #{sig_path} #{data_path}
    SH
  end

  def msg_mismatch(text)
    "expected given signature to be a valid Open PGP signature " +
      "of following text:\n#{text}"
  end

  def msg_no_pgg_data(file_text)
    "expected given text to be a valid Open PGP signature, " +
      "but it contains no PGP data, just:\n#{file_text}"
  end

  def msg_wrong_signer(actual_signer)
    "expected singature to be signed by #{expected_signer}, " +
      "but was actually signed by #{actual_signer}"
  end
end
