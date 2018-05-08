require "spec_helper"

RSpec.describe EnMail::Helpers::RFC1847 do
  let(:adapter) { EnMail::Adapters::Base.new(options).extend(described_class) }
  let(:options) { {} }

  include_context "example emails"

  let(:custom_sign_protocol) { "application/custom-signed" }
  let(:custom_enc_protocol) { "application/custom-encrypted" }
  let(:custom_micalg) { "custom-micalg" }

  before do
    allow(adapter).
      to receive(:sign_protocol).and_return(custom_sign_protocol)
    allow(adapter).
      to receive(:encryption_protocol).and_return(custom_enc_protocol)
    allow(adapter).
      to receive(:message_integrity_algorithm).and_return(custom_micalg)
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

  describe "#build_encrypted_part" do
    subject { adapter.method(:build_encrypted_part) }
    let(:part) { ::Mail::Part.new(body: "Some Text.") }
    let(:recipients) { %w[senate@example.test] }

    before do
      allow(adapter).to receive(:encrypt_string).and_return("DUMMY")
    end

    it "builds a MIME part with correct content type" do
      retval = subject.(part, recipients)
      expect(retval).to be_instance_of(::Mail::Part)
      expect(retval.mime_type).to eq("application/octet-stream")
      expect(retval.body.decoded).to eq("DUMMY")
    end

    it "encrypts with keys matching given recipients" do
      subject.(part, recipients)
      expect(adapter).to have_received(:encrypt_string).
        with(kind_of(String), recipients)
    end
  end

  describe "#build_encryption_control_part" do
    subject { adapter.method(:build_encryption_control_part) }

    before do
      allow(adapter).
        to receive(:encryption_control_information).and_return("DUMMY")
    end

    it "builds a MIME part with correct content type" do
      retval = subject.call
      expect(retval).to be_instance_of(::Mail::Part)
      expect(retval.mime_type).to eq(custom_enc_protocol)
      expect(retval.body.decoded).to eq("DUMMY")
    end
  end

  describe "#build_signature_part" do
    subject { adapter.method(:build_signature_part) }
    let(:part) { ::Mail::Part.new(body: "Some Text.") }
    let(:signer) { "some.signer@example.com" }

    before do
      allow(adapter).to receive(:compute_signature).and_return("DUMMY")
    end

    it "builds a MIME part with correct content type" do
      retval = subject.(part, signer)
      expect(retval).to be_instance_of(::Mail::Part)
      expect(retval.mime_type).to eq(custom_sign_protocol)
      expect(retval.body.decoded).to eq("DUMMY")
    end

    it "signs with key matching given signer" do
      subject.(part, signer)
      expect(adapter).to have_received(:compute_signature).
        with(kind_of(String), signer)
    end
  end

  describe "#multipart_signed_content_type" do
    subject { adapter.method(:multipart_signed_content_type) }

    it "returns a string" do
      expect(subject.call).to be_a(String)
    end

    it "has a MIME type multipart/signed" do
      retval_segments = subject.call.split(/\s*;\s*/)
      expect(retval_segments[0]).to eq("multipart/signed")
    end

    it "tells about SHA1 message integrity algorithm" do
      retval_segments = subject.call.split(/\s*;\s*/)
      micalg_def = %[micalg="#{custom_micalg}"]
      expect(retval_segments[1..-1]).to include(micalg_def)
    end

    it "tells about PGP protocol" do
      retval_segments = subject.call.split(/\s*;\s*/)
      protocol_def = %[protocol="#{custom_sign_protocol}"]
      expect(retval_segments[1..-1]).to include(protocol_def)
    end
  end

  describe "#multipart_encrypted_content_type" do
    subject { adapter.method(:multipart_encrypted_content_type) }

    it "returns a string" do
      expect(subject.call).to be_a(String)
    end

    it "has a MIME type multipart/encrypted" do
      retval_segments = subject.call.split(/\s*;\s*/)
      expect(retval_segments[0]).to eq("multipart/encrypted")
    end

    it "tells about PGP protocol" do
      retval_segments = subject.call.split(/\s*;\s*/)
      protocol_def = %[protocol="#{custom_enc_protocol}"]
      expect(retval_segments[1..-1]).to include(protocol_def)
    end
  end
end
