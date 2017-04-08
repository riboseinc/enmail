require "spec_helper"

RSpec.describe EnMail::Config do
  describe ".configure" do
    it "allows us to set custom configuration" do
      certificates_path = File.expand_path("../../fixtures", __FILE__)

      EnMail.configure do |enmail_config|
        enmail_config.sign_message = true
        enmail_config.certificates_path = certificates_path
      end

      expect(EnMail.configuration.signable?).to be_truthy
      expect(EnMail.configuration.certificates_path).to eq(certificates_path)
    end
  end
end
