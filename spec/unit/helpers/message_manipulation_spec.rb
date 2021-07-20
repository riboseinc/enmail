# (c) Copyright 2018 Ribose Inc.
#

require "spec_helper"

RSpec.describe EnMail::Helpers::MessageManipulation do
  let(:adapter) { EnMail::Adapters::Base.new(options).extend(described_class) }
  let(:options) { {} }

  include_context "example emails"

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

  describe "#duplicate_part" do
    subject { adapter.method(:duplicate_part) }

    shared_examples "examples for #duplicate_part" do
      it "returns a different MIME part" do
        expect(subject.(source_part)).not_to equal(source_part)
      end

      it "duplicates in a way that encoded source and target are equal" do
        dup = subject.(source_part)
        expect(dup.to_s).to eq(source_part.to_s) & be_a(String) & match(/\w/)
      end

      it "preserves Content-ID in duplicated MIME part" do
        source_part.add_content_id("123")
        dup = subject.(source_part)
        expect(dup.content_id).to eq(source_part.content_id) & eq("123")
      end

      it "does not add a Content-ID unless source MIME part has one" do
        # Condition below may seem excessive, but has been added due to some bug
        # in the Mail 2.7.1 gem.  It appears that doing `content_id = nil` when
        # `content_id` is already `nil`, actually generates a random Content-ID,
        # and assigns it to given MIME part.
        source_part.content_id = nil if source_part.content_id
        dup = subject.(source_part)
        expect(dup.content_id).to eq(source_part.content_id) & be(nil)
      end
    end

    context "for textual MIME part" do
      let(:source_part) { text_jpeg_mail.parts[0] }
      include_examples "examples for #duplicate_part"
    end

    context "for binary MIME part" do
      let(:source_part) { text_jpeg_mail.parts[1] }
      include_examples "examples for #duplicate_part"
    end

    context "for compound MIME part" do
      let(:source_part) do
        text_part = Mail::Part.new
        text_part.body = "Whatever"

        part = Mail::Part.new
        part.add_part text_part
        part.add_file filename: "pic.jpg", content: SMALLEST_JPEG
        part
      end
      include_examples "examples for #duplicate_part"
    end
  end

  describe "#find_recipients_for" do
    subject { adapter.method(:find_recipients_for) }
    let(:mail) { simple_mail }

    it "returns all addresses from e-mail To: field" do
      expect(subject.(mail)).to eq([mail_to])
    end
  end

  describe "#find_signer_for" do
    subject { adapter.method(:find_signer_for) }
    let(:mail) { simple_mail }

    it "returns first address from e-mail From: field unless adapter's " +
      ":signer option is set" do
      expect(subject.(mail)).to eq(mail_from)
    end
    it "returns adapter's :signer option if such option is set" do
      options[:signer] = "overwritten@example.test"
      expect(subject.(mail)).to eq("overwritten@example.test")
    end
  end

  describe "#rewrite_body" do
    subject { adapter.method(:rewrite_body) }
    let(:part1) { ::Mail::Part.new(body: "Some Text.") }
    let(:part2) { ::Mail::Part.new(body: "More Text.") }
    let(:new_parts) { [part1, part2] }
    let(:args) { [mail, content_type: "multipart/whatever", parts: new_parts] }

    shared_examples "shared examples for #rewrite_body" do
      it "replaces existing body with given parts" do
        subject.(*args)
        expect(mail.parts).to eq(new_parts)
      end

      it "preserves from, to, subject, date, message id, and custom headers" do
        mail.ready_to_send! # Set some default message_id
        expect { subject.(*args) }.to(
          preserve { mail.date } &
          preserve { mail.from } &
          preserve { mail.to } &
          preserve { mail.subject } &
          preserve { mail.message_id } &
          preserve { mail.headers["custom"] }
        )
      end
    end

    context "for a non-multipart message" do
      let(:mail) { simple_html_mail }

      include_examples "shared examples for #rewrite_body"

      it "removes previous body" do
        expect { subject.(*args) }.to(
          change { mail.body.decoded.include?(mail_html) }.to(false)
        )
      end
    end

    context "for a multipart message" do
      let(:mail) { text_jpeg_mail }

      include_examples "shared examples for #rewrite_body"

      it "removes previous body parts" do
        old_parts = mail.parts.dup

        expect { subject.(*args) }.to(
          change { mail.body.parts.include?(old_parts[0]) }.to(false) &
          change { mail.body.parts.include?(old_parts[1]) }.to(false)
        )
      end
    end
  end
end
