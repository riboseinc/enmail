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
      expect(adapter).to have_received(:build_encrypted_part).with(msg_part_dbl)
      expect(mail.parts[1]).to be(enc_part_dbl)
    end
  end

  describe "#body_to_part" do
    subject { adapter.method(:body_to_part) }

    it "converts an e-mail with unspecified content type to " +
      "a text/plain MIME part, preserving its content" do
      mail = simple_mail
      retval = subject.(mail)
      expect(retval).to be_instance_of(::Mail::Part)
      expect(retval.mime_type).to eq(mail.mime_type) & eq(nil)
      expect(retval.body.decoded).to eq(mail.body.decoded)
    end

    it "converts a non-multipart e-mail with specific content type to " +
      "a MIME part, preserving its content and content type" do
      mail = simple_html_mail
      retval = subject.(mail)
      expect(retval).to be_instance_of(::Mail::Part)
      expect(retval.mime_type).to eq(mail.mime_type) & eq("text/html")
      expect(retval.body.decoded).to eq(mail.body.decoded)
    end

    it "converts a multipart e-mail into a multipart MIME part, " +
      "preserving its content and content type" do
      mail = text_jpeg_mail
      retval = subject.(mail)
      expect(retval).to be_instance_of(::Mail::Part)
      expect(retval.mime_type).to eq(mail.mime_type)
      expect(retval.parts.size).to eq(mail.parts.size) & eq(2)
      expect(retval.parts[0]).to eq(mail.parts[0])
      expect(retval.parts[1]).to eq(mail.parts[1])
    end
  end

  describe "#build_signature_part" do
    subject { adapter.method(:build_signature_part) }
    let(:part) { ::Mail::Part.new(body: "Some Text.") }
    let(:signer) { "some.signer@example.com" }
    let(:signature_rx) { %r{\A-+BEGIN PGP SIGNATURE.*END PGP SIGNATURE-+\Z}m }

    it "builds a MIME part with correct content type" do
      retval = subject.(part, signer)
      expect(retval).to be_instance_of(::Mail::Part)
      expect(retval.mime_type).to eq("application/pgp-signature")
      expect(retval.body.decoded).to match(signature_rx)
    end

    it "signs with key matching given signer" do
      crypto_dbl = double
      allow(adapter).to receive(:build_crypto).and_return(crypto_dbl)
      expect(crypto_dbl).to receive(:detach_sign).
        with(kind_of(String), signer: signer)
      subject.(part, signer)
    end
  end

  describe "#build_encrypted_part" do
    subject { adapter.method(:build_encrypted_part) }
    let(:part) { ::Mail::Part.new(body: "Some Text.") }
    let(:pgp_msg_rx) { %r{\A-+BEGIN PGP MESSAGE.*END PGP MESSAGE-+\Z}m }

    it "builds a MIME part with correct content type" do
      retval = subject.(part)
      expect(retval).to be_instance_of(::Mail::Part)
      expect(retval.mime_type).to eq("application/octet-stream")
      expect(retval.body.decoded).to eq("DUMMY")
      pending "Insert actual PGP message into part body"
      expect(retval.body.decoded).to match(pgp_msg_rx)
    end

    it "encrypts with keys matching given recipients"
  end

  describe "#signed_part_content_type" do
    subject { adapter.method(:signed_part_content_type) }

    it "returns a string" do
      expect(subject.call).to be_a(String)
    end

    it "has a MIME type multipart/signed" do
      retval_segments = subject.call.split(/\s*;\s*/)
      expect(retval_segments[0]).to eq("multipart/signed")
    end

    it "tells about SHA1 message integrity algorithm" do
      retval_segments = subject.call.split(/\s*;\s*/)
      micalg_def = %[micalg="pgp-sha1"]
      expect(retval_segments[1..-1]).to include(micalg_def)
    end

    it "tells about PGP protocol" do
      retval_segments = subject.call.split(/\s*;\s*/)
      protocol_def = %[protocol="application/pgp-signature"]
      expect(retval_segments[1..-1]).to include(protocol_def)
    end
  end

  describe "#encrypted_part_content_type" do
    subject { adapter.method(:encrypted_part_content_type) }

    it "returns a string" do
      expect(subject.call).to be_a(String)
    end

    it "has a MIME type multipart/encrypted" do
      retval_segments = subject.call.split(/\s*;\s*/)
      expect(retval_segments[0]).to eq("multipart/encrypted")
    end

    it "tells about PGP protocol" do
      retval_segments = subject.call.split(/\s*;\s*/)
      protocol_def = %[protocol="application/pgp-encrypted"]
      expect(retval_segments[1..-1]).to include(protocol_def)
    end
  end
end
