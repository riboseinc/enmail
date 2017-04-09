require "spec_helper"
require "enmail/enmailable"

RSpec.describe "EnMail::TestEnMailble" do
  describe "#signing_key" do
    context "custom key provided" do
      it "returns the custom key as signing key" do
        EnMail.configuration.sign_key = "default_key"
        custom_key = EnMail::Key.new(sign_key: "custom secret key")

        message = EnMail::TestEnMailble.new
        message.sign(key: custom_key)

        expect(message.signing_key).to eq(custom_key)
      end
    end

    context "without any key provided" do
      it "returns the default configuration" do
        default_key = "default secret key"
        EnMail.configuration.sign_key = default_key

        message = EnMail::TestEnMailble.new
        message.sign

        expect(message.signing_key.sign_key).to eq(default_key)
      end
    end
  end

  describe "#signable?" do
    context "without a signing_key" do
      it "returns false" do
        EnMail.configuration.sign_key = nil

        message = EnMail::TestEnMailble.new
        message.sign

        expect(message.signable?).to be_falsey
      end
    end

    context "with a valid signing key" do
      it "returns true" do
        EnMail.configuration.sign_message = true
        sign_key = EnMail::Key.new(sign_key: "valid signing key")

        message = EnMail::TestEnMailble.new
        message.sign(key: sign_key)

        expect(message.signable?).to be_truthy
      end
    end
  end

  module EnMail
    class TestEnMailble
      include EnMail::EnMailable
    end
  end
end
