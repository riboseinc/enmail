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
