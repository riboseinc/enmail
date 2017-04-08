require "spec_helper"
require "enmail/mail_ext/message"

RSpec.describe "Mail::Message" do
  describe "custom interfaces" do
    it "includes EnMail::EnMailable module" do
      expect(Mail::Message.included_modules).to include(EnMail::EnMailable)
    end
  end
end
