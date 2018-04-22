require "spec_helper"

RSpec.describe "Sign an email" do
  it "signs an email using the adapter" do
    mail = Mail.new(
      from: "enmail@ribosetest.com",
      body: "This text is going to be signed",
    )

    mail.perform_deliveries = false
    mail.sign(key: enmail_key)

    mail.deliver
    message_body = mail.body.raw_source

    expect(message_body).to match(/This text is going to be signed/)
    expect(message_body).to match(/Content-Type: multipart\/signed;/)
    expect(message_body).to match(/This is an S\/MIME signed message/)
  end

  def enmail_key
    EnMail::Key.new(
      sign_key: enmail_key_content,
      certificate: enmail_certificate_content
    )
  end

  def enmail_key_content
    File.read(enmail_fixture_file)
  end

  def enmail_certificate_content
    File.read(enmail_fixture_file("pem"))
  end

  def enmail_fixture_file(ext = "key")
    File.expand_path("../../fixtures/enmail.ribosetest.com.#{ext}", __FILE__)
  end
end
