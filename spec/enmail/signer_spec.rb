require "spec_helper"

RSpec.describe EnMail::Signer do
  describe ".sign" do
    it "signs a signable message" do
      key = "This supossed to be the secret key"
      message = "This supossed to be the message"

      signer = EnMail::Signer.new(key: key, message: message)
      signer.sign

      puts signer.signed_data
    end
  end
end
