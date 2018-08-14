# (c) Copyright 2018 Ribose Inc.
#

require "spec_helper"

RSpec.describe :be_a_pgp_encrypted_message do
  subject { method(:be_a_pgp_encrypted_message) }
  let(:failure_exception) { RSpec::Expectations::ExpectationNotMetError }
  let(:crypto) { ::GPGME::Crypto.new(crypto_opts) }
  let(:enc) { crypto.encrypt(text).to_s }
  let(:text) { "text" }
  let(:misspelled) { "teXt" }
  let(:recipient) { "whatever@example.test" }
  let(:signer) { "whatever@example.test" }

  let(:crypto_opts) do
    { armor: true, recipients: [recipient], signers: signer, sign: true }
  end

  it "assures that string contains PGP data" do
    m = subject.call.containing(text)
    expect(m.matches?("a ")).to be(false)
  end

  it "assures that string is an encrypted message which contains given text" do
    m = subject.call.containing(text)
    expect(m.matches?(enc)).to be(true)

    m = subject.call.containing(misspelled)
    expect(m.matches?(enc)).to be(false)
  end

  it "assures that string is an encrypted message for correct recipients" do
    m = subject.call.containing(text).encrypted_for(recipient)
    expect(m.matches?(enc)).to be(true)

    m = subject.call.containing(text).encrypted_for("a@example.test")
    expect(m.matches?(enc)).to be(false)

    m = subject.call.containing(misspelled).encrypted_for(recipient)
    expect(m.matches?(enc)).to be(false)
  end

  it "assures that string is an encrypted message signed with correct key" do
    m = subject.call.containing(text).signed_by(signer)
    expect(m.matches?(enc)).to be(true)

    m = subject.call.containing(text).signed_by("a@example.test")
    expect(m.matches?(enc)).to be(false)

    m = subject.call.containing(misspelled).signed_by(signer)
    expect(m.matches?(enc)).to be(false)
  end

  it "checks more than one recipient, in any order" do
    recipient1 = "whatever@example.test"
    recipient2 = "senate@example.test"
    wrong_recipient = "a@example.test"
    crypto_opts[:recipients] = [recipient1, recipient2]

    m = subject.call.containing(text).encrypted_for(recipient1, recipient2)
    expect(m.matches?(enc)).to be(true)

    # It's okay to reverse recipients
    m = subject.call.containing(text).encrypted_for(recipient2, recipient1)
    expect(m.matches?(enc)).to be(true)

    # It's not okay to skip recipients
    m = subject.call.containing(text).encrypted_for(recipient1)
    expect(m.matches?(enc)).to be(false)

    m = subject.call.containing(text).encrypted_for(recipient2)
    expect(m.matches?(enc)).to be(false)

    # Decrypted text is still checked, if constraint is specified
    m = subject.call.
      containing(misspelled).encrypted_for(recipient1, recipient2)
    expect(m.matches?(enc)).to be(false)

    m = subject.call.encrypted_for(recipient1, recipient2)
    expect(m.matches?(enc)).to be(true)

    # It's not okay to add recipients
    m = subject.call.
      containing(text).encrypted_for(recipient1, recipient2, wrong_recipient)
    expect(m.matches?(enc)).to be(false)

    m = subject.call.encrypted_for(recipient1, recipient2, wrong_recipient)
    expect(m.matches?(enc)).to be(false)

    m = subject.call.containing(text).encrypted_for(wrong_recipient)
    expect(m.matches?(enc)).to be(false)
  end
end

RSpec.describe :be_a_valid_pgp_signature_of do
  subject { method(:be_a_valid_pgp_signature_of) }
  let(:failure_exception) { RSpec::Expectations::ExpectationNotMetError }
  let(:crypto) { ::GPGME::Crypto.new(armor: true, signer: signer) }
  let(:sig) { crypto.detach_sign(text).to_s }
  let(:text) { "text" }
  let(:misspelled) { "teXt" }
  let(:signer) { "whatever@example.test" }

  it "assures that string contains PGP data" do
    m = subject.(text)
    expect(m.matches?("a ")).to be(false)
  end

  it "assures that string is a valid signature of given text" do
    m = subject.(text)
    expect(m.matches?(sig)).to be(true)

    m = subject.(misspelled)
    expect(m.matches?(sig)).to be(false)
  end

  it "assures that string is signed with correct key" do
    m = subject.(text).signed_by(signer)
    expect(m.matches?(sig)).to be(true)

    m = subject.(text).signed_by("a@example.test")
    expect(m.matches?(sig)).to be(false)

    m = subject.(misspelled).signed_by(signer)
    expect(m.matches?(sig)).to be(false)
  end
end
