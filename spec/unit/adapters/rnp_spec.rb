# (c) Copyright 2018 Ribose Inc.
#

require "spec_helper"

RSpec.describe EnMail::Adapters::RNP, requires: :rnp do
  let(:adapter) { described_class.new(options) }
  let(:options) { {} }

  include_context "example emails"

  describe ":homedir option" do
    before do
      allow(Rnp).to receive(:new).
        and_return(double.as_null_object)
      allow(Rnp).to receive(:homedir_info).
        and_return(public: { path: "." }, secret: { path: "." })
      allow(Rnp).to receive(:default_homedir).
        and_return("default/rnp/home")
    end

    it "allows to override homedir" do
      described_class.new homedir: "some/path"
      expect(Rnp).to have_received(:homedir_info).with("some/path")
    end

    it "defaults to Rnp.default_homedir" do
      described_class.new Hash.new
      expect(Rnp).to have_received(:homedir_info).with("default/rnp/home")
    end
  end

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

  describe "#sign_and_encrypt_string" do
    subject { adapter.method(:sign_and_encrypt_string) }
    let(:text) { "Some Text." }
    let(:recipients) { %w[whatever@example.test senate@example.test] }
    let(:signer) { "cato.elder@example.test" }

    it "encrypts given text" do
      retval = subject.(text, signer, recipients)
      expect(retval).to be_a_pgp_encrypted_message.containing(text)
    end

    it "makes the encrypted text readable for given recipients" do
      retval = subject.(text, signer, recipients)
      expect(retval).to be_a_pgp_encrypted_message.encrypted_for(*recipients)
    end

    it "adds a signature by given user to the encrypted text" do
      retval = subject.(text, signer, recipients)
      expect(retval).to be_a_pgp_encrypted_message.signed_by(signer)
    end
  end
end
