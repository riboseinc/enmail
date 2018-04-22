require "spec_helper"

RSpec.describe EnMail::Encrypter do
  describe ".sign" do
    it "signs the message using the adapter" do
      message = message_double
      signed_data = EnMail::Encrypter.sign(message)

      expect(signed_data).to match(message.encoded)
      expect(signed_data).to match(/Content-Type: multipart\/signed;/)
    end
  end

  def message_double
    double("Mail", encoded: "The encoded content", key: enmail_key_instance)
  end

  def enmail_key_instance
    EnMail::Key.new(
      sign_key: enmail_key_content,
      certificate: enmail_certificate,
    )
  end

  def enmail_key_content
    File.read(enmail_key_file)
  end

  def enmail_certificate
    File.read(enmail_key_file("pem"))
  end

  def enmail_key_file(ext = "key")
    File.expand_path("../../fixtures/enmail.ribosetest.com.#{ext}", __FILE__)
  end
end
