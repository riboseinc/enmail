require "spec_helper"

RSpec.describe "Signing" do
  it "signs an email instance" do
    mail = Mail.new
    mail.perform_deliveries = false
    # mail.delivery_method(:test)

    # allow(mail).to receive(:deliver)
    allow(EnMail::Signer).to receive(:sign)

    mail.sign("This should be my key")
    mail.deliver

    expect(EnMail::Signer).to have_received(:sign).with(mail)
  end
end
