require "spec_helper"

RSpec.describe EnMail::Helpers::RFC3156 do
  let(:adapter) { EnMail::Adapters::Base.new(options).extend(described_class) }
  let(:options) { {} }

  include_context "example emails"

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
