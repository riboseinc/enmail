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
      expect(adapter).to have_received(:build_signature_part).with(msg_part_dbl)
      expect(mail.parts[1]).to be(sig_dbl)
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

    it "builds a MIME part with correct content type" do
      retval = subject.(part)
      expect(retval).to be_instance_of(::Mail::Part)
      expect(retval.mime_type).to eq("application/pgp-signature")
      expect(retval.body.decoded).to eq("DUMMY_SIGNATURE")
    end
  end
end
