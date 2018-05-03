require "spec_helper"

RSpec.describe :be_a_valid_pgp_signature_of do
  let(:failure_exception) { RSpec::Expectations::ExpectationNotMetError }
  let(:crypto) { ::GPGME::Crypto.new(armor: true, signer: signer) }
  let(:sig) { crypto.detach_sign(text).to_s }
  let(:text) { "text" }
  let(:misspelled) { "teXt" }
  let(:signer) { "whatever@example.test" }

  it "assures that string contains PGP data" do
    m = be_a_valid_pgp_signature_of(text)
    expect(m.matches?("a ")).to be(false)
  end

  it "assures that string is a valid signature of given text" do
    m = be_a_valid_pgp_signature_of(text)
    expect(m.matches?(sig)).to be(true)

    m = be_a_valid_pgp_signature_of(misspelled)
    expect(m.matches?(sig)).to be(false)
  end

  it "assures that string is signed with correct key" do
    m = be_a_valid_pgp_signature_of(text).signed_by(signer)
    expect(m.matches?(sig)).to be(true)

    m = be_a_valid_pgp_signature_of(text).signed_by("a@example.test")
    expect(m.matches?(sig)).to be(false)

    m = be_a_valid_pgp_signature_of(misspelled).signed_by(signer)
    expect(m.matches?(sig)).to be(false)
  end
end
