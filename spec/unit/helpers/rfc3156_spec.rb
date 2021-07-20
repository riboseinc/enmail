# (c) Copyright 2018 Ribose Inc.
#

require "spec_helper"

RSpec.describe EnMail::Helpers::RFC3156 do
  let(:adapter) { EnMail::Adapters::Base.new(options).extend(described_class) }
  let(:options) { {} }

  include_context "example emails"

  describe "#sign_and_encrypt_combined" do
    subject { adapter.method(:sign_and_encrypt_combined) }

    let(:mail) { simple_mail }
    let(:blank_string_rx) { /\A\s*\Z/ }
    let(:msg_part_dbl) { double.as_null_object }
    let(:msg_ctrl_dbl) { double.as_null_object }
    let(:enc_part_dbl) { double.as_null_object }
    let(:enc_dummy) { "DUMMY-PGP-MESSAGE" }

    before do
      allow(adapter).to receive(:body_to_part).and_return(msg_part_dbl)
      allow(adapter)
        .to receive(:build_encryption_control_part).and_return(msg_ctrl_dbl)
      allow(adapter)
        .to receive(:build_encrypted_part).and_return(enc_part_dbl)
      allow(adapter)
        .to receive(:sign_and_encrypt_string).and_return(enc_dummy)
      allow(adapter).to receive(:restrict_encoding)
    end

    it "changes message mime type to multipart/encrypted" do
      expect { subject.(mail) }.to(
        change { mail.mime_type }.to("multipart/encrypted")
      )
    end

    it "preserves from, to, subject, date, message id, and custom headers" do
      mail.ready_to_send! # Set some default message_id
      expect { subject.(mail) }.to(
        preserve { mail.date } &
        preserve { mail.from } &
        preserve { mail.to } &
        preserve { mail.subject } &
        preserve { mail.message_id } &
        preserve { mail.headers["custom"] }
      )
    end

    it "clears the old message body" do
      expect { subject.(mail) }
        .to change { mail.body.decoded }.to(blank_string_rx)
    end

    it "adds the control information as the 1st MIME part" do
      subject.(mail)
      expect(adapter)
        .to have_received(:build_encryption_control_part).with(no_args)
      expect(mail.parts[0]).to be(msg_ctrl_dbl)
    end

    it "converts the old message body to a a MIME part, and encrypts, " +
      "and signs it in a single OpenPGP message" do
      subject.(mail)
      expect(adapter).to have_received(:body_to_part).with(mail)
      expect(adapter).to have_received(:sign_and_encrypt_string)
        .with(msg_part_dbl, mail_from, [mail_to])
    end

    it "adds the signed and encrypted message as the 2nd MIME part" do
      subject.(mail)
      expect(adapter).to have_received(:build_encrypted_part).with(enc_dummy)
      expect(mail.parts[1]).to be(enc_part_dbl)
    end

    it "enforces quoted-printable or base64 transport encoding for part " +
      "containing original message (before encryption), but for nothing else" do
      subject.(mail)
      expect(adapter).to have_received(:restrict_encoding).once
      expect(adapter).to have_received(:restrict_encoding).with(msg_part_dbl)
    end
  end

  describe "#sign_and_encrypt_encapsulated" do
    subject { adapter.method(:sign_and_encrypt_encapsulated) }

    let(:mail) { simple_mail }

    it "signs and encrypts the message, in that exact order" do
      expect(adapter).to receive(:sign).with(mail).ordered
      expect(adapter).to receive(:encrypt).with(mail).ordered
      subject.(mail)
    end
  end
end
