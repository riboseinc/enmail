require "spec_helper"

RSpec.describe EnMail::Key do
  describe "attributes" do
    it "responds to key attributes" do
      key = EnMail::Key.new(key_attributes)

      expect(key.sign_key).to eq(key_attributes[:sign_key])
      expect(key.passphrase).to eq(key_attributes[:passphrase])
      expect(key.encrypt_key).to eq(key_attributes[:encrypt_key])
      expect(key.certificate).to eq(key_attributes[:certificate])
    end
  end

  def key_attributes
    @attributes ||= {
      sign_key: "signing key content",
      passphrase: "sign_key passphrase",
      encrypt_key: "encryping key content",
      certificate: "signing certificate content"
    }
  end
end
