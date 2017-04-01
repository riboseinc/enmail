require "spec_helper"

RSpec.describe EnMail::Interceptor do
  describe ".delivering_email" do
    it "sends sign message to the signer" do
      allow(EnMail::Signer).to receive(:sign)

      EnMail::Interceptor.delivering_email(message_double)

      expect(EnMail::Signer).to have_received(:sign).with(message_double)
    end
  end

  def message_double
    @message ||= double("Mail", body: "Message Body", signer: "john@doe.com")
  end
end
