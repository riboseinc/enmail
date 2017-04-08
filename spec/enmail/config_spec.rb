require "spec_helper"

RSpec.describe EnMail::Config do
  describe ".configure" do
    it "allows us to set custom configuration" do
      certificates_path = File.expand_path("../../fixtures", __FILE__)

      EnMail.configure do |enmail_config|
        enmail_config.sign_message = true
        enmail_config.secret_key = "Secret key content"
        enmail_config.certificates_path = certificates_path
      end

      expect(EnMail.configuration.signable?).to be_truthy
      expect(EnMail.configuration.secret_key).not_to be_nil
      expect(EnMail.configuration.certificates_path).to eq(certificates_path)
    end
  end

  describe "configuring adapter" do
    context "with supported adapter" do
      it "allows us to set the adapter" do
        smime_adapter = :openssl

        EnMail.configure do |config|
          config.smime_adapter = smime_adapter
        end

        expect(EnMail.configuration.smime_adapter).to eq(smime_adapter)
      end
    end

    context "with non supported adapter" do
      it "usages the defualt adapter" do
        invalid_adapter = :invalidadapter
        EnMail.configuration.smime_adapter = invalid_adapter

        expect(EnMail.configuration.smime_adapter).not_to be(invalid_adapter)
      end
    end
  end
end
