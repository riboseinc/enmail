require "spec_helper"

RSpec.describe EnMail::Interceptor do
  describe ".delivering_email" do
    it "sends sign message to the enmailer" do
      allow(message_double).to receive(:body=)
      allow(EnMail::Encrypter).to receive(:sign)

      EnMail::Interceptor.delivering_email(message_double)

      expect(
        EnMail::Encrypter,
      ).to have_received(:sign).with(message_double)
    end
  end

  def message_double
    @message_double ||= double(
      "Mail",
      signable?: true,
      body: "Message Body",
      from: ["enmail@ribosetest.com"],
    )
  end
end
