require "spec_helper"

RSpec.describe EnMail::Adapters::GPGME do
  let(:adapter) { described_class.new(options) }
  let(:options) { {} }

  include_context "example emails"

  describe "#sign" do
    subject { adapter.method(:sign) }

    let(:mail) { simple_mail }
    let(:blank_string_rx) { /\A\s*\Z/ }
    let(:msg_part_dbl) { double.as_null_object }
    let(:sig_dbl) { double.as_null_object }

    before do
      allow(adapter).to receive(:body_to_part).and_return(msg_part_dbl)
      allow(adapter).to receive(:build_signature_part).and_return(sig_dbl)
    end

    it "changes message mime type to multipart/signed" do
      expect { subject.(mail) }.to(
        change { mail.mime_type }.to("multipart/signed")
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
      expect { subject.(mail) }.
        to change { mail.body.decoded }.to(blank_string_rx)
    end

    it "converts the old message body to a a MIME part, and re-appends it " +
      "to self" do
      subject.(mail)
      expect(adapter).to have_received(:body_to_part).with(mail)
      expect(mail.parts[0]).to be(msg_part_dbl)
    end

    it "adds the signature as the 2nd MIME part" do
      subject.(mail)
      expect(adapter).to have_received(:build_signature_part).
        with(msg_part_dbl, mail_from)
      expect(mail.parts[1]).to be(sig_dbl)
    end
  end

  describe "#encrypt" do
    subject { adapter.method(:encrypt) }

    let(:mail) { simple_mail }
    let(:blank_string_rx) { /\A\s*\Z/ }
    let(:msg_part_dbl) { double.as_null_object }
    let(:msg_ctrl_dbl) { double.as_null_object }
    let(:enc_part_dbl) { double.as_null_object }

    before do
      allow(adapter).to receive(:body_to_part).and_return(msg_part_dbl)
      allow(adapter).
        to receive(:build_encryption_control_part).and_return(msg_ctrl_dbl)
      allow(adapter).
        to receive(:build_encrypted_part).and_return(enc_part_dbl)
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
      expect { subject.(mail) }.
        to change { mail.body.decoded }.to(blank_string_rx)
    end

    it "adds the control information as the 1st MIME part" do
      subject.(mail)
      expect(adapter).
        to have_received(:build_encryption_control_part).with(no_args)
      expect(mail.parts[0]).to be(msg_ctrl_dbl)
    end

    it "converts the old message body to a a MIME part, encrypts, " +
      "and re-appends it to self as the 2nd MIME part" do
      subject.(mail)
      expect(adapter).to have_received(:body_to_part).with(mail)
      expect(adapter).to have_received(:build_encrypted_part).
        with(msg_part_dbl, [mail_to])
      expect(mail.parts[1]).to be(enc_part_dbl)
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
