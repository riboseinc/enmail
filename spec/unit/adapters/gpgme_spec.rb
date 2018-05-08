require "spec_helper"

RSpec.describe EnMail::Adapters::GPGME do
  let(:adapter) { described_class.new(options) }
  let(:options) { {} }

  include_context "example emails"

  describe "#compute_signature" do
    subject { adapter.method(:compute_signature) }
    let(:text) { "Some Text." }
    let(:signer) { "cato.elder@example.test" }

    it "computes a detached signature for given text signed by given user" do
      retval = subject.(text, signer)
      expect(retval).to be_a_valid_pgp_signature_of(text).signed_by(signer)
    end
  end

  describe "#encrypt_string" do
    subject { adapter.method(:encrypt_string) }
    let(:text) { "Some Text." }
    let(:recipients) { %w[whatever@example.test senate@example.test] }

    it "encrypts given text" do
      retval = subject.(text, recipients)
      expect(retval).to be_a_pgp_encrypted_message.containing(text)
    end

    it "makes the encrypted text readable for given recipients" do
      retval = subject.(text, recipients)
      expect(retval).to be_a_pgp_encrypted_message.encrypted_for(*recipients)
    end
  end
end
