# (c) Copyright 2018 Ribose Inc.
#

require "spec_helper"

RSpec.describe EnMail::Adapters::GPGME, requires: :gpgme do
  let(:adapter) { described_class.new(options) }
  let(:options) { {} }

  include_context "example emails"

  describe "#compute_signature" do
    subject { adapter.method(:compute_signature) }
    let(:text) { "Some Text." }
    let(:signer) { "cato.elder@example.test" }
    let(:signer_with_password) { "cato.elder+pwd@example.test" }
    let(:valid_password) { "1234" }

    it "returns a two element array" do
      retval = subject.(text, signer)
      expect(retval).to be_an(Array)
      expect(retval.size).to eq(2)
    end

    it "computes a detached signature for given text signed by given " +
      "user, and returns it as 2nd element of the returned array" do
      retval = subject.(text, signer)
      expect(retval[1]).to be_a_valid_pgp_signature_of(text).signed_by(signer)
    end

    it "returns a digest algorithm as 1st element of the returned array" do
      retval = subject.(text, signer)
      expect(retval[0]).to match(/\Apgp-[a-z0-9]+\z/)
    end

    it "can sign with a password-protected key" do
      options[:key_password] = valid_password
      retval = subject.(text, signer_with_password)
      expect(retval[1]).
        to be_a_valid_pgp_signature_of(text).signed_by(signer_with_password)
    end

    it "raises exception when key password is missing for " +
      "a password-protected key" do
      expect { subject.(text, signer_with_password) }.
        to raise_exception(::GPGME::Error::General)
    end

    it "raises exception when key password is invalid" do
      invalid_password = valid_password + "5"
      options[:key_password] = invalid_password
      expect { subject.(text, signer_with_password) }.
        to raise_exception(::GPGME::Error::BadPassphrase)
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
    let(:signer_with_password) { "cato.elder+pwd@example.test" }
    let(:valid_password) { "1234" }

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

    it "can sign with a password-protected key" do
      options[:key_password] = valid_password
      retval = subject.(text, signer_with_password, recipients)
      expect(retval).
        to be_a_pgp_encrypted_message.signed_by(signer_with_password)
    end

    it "raises exception when key password is missing for " +
      "a password-protected key" do
      expect { subject.(text, signer_with_password, recipients) }.
        to raise_exception(::GPGME::Error::General)
    end

    it "raises exception when key password is invalid" do
      invalid_password = valid_password + "5"
      options[:key_password] = invalid_password
      expect { subject.(text, signer_with_password, recipients) }.
        to raise_exception(::GPGME::Error::BadPassphrase)
    end
  end
end
