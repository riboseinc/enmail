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
end
