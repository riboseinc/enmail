require "spec_helper"
require "enmail/enmailable"

RSpec.describe "EnMail::TestEnMailble" do
  describe "#signable?" do
    context "without invoking #sign on message" do
      it "usages the default configuration" do
        EnMail.configuration.sign_message = false
        enmailable = EnMail::TestEnMailble.new

        expect(enmailable.signable?).to be_falsey
      end
    end

    context "with explicity calling sign interface" do
      it "sets the message signing status to true" do
        EnMail.configuration.sign_message = false

        enmailable = EnMail::TestEnMailble.new
        enmailable.sign

        expect(enmailable.signable?).to be_truthy
      end
    end
  end

  module EnMail
    class TestEnMailble
      include EnMail::EnMailable
    end
  end
end
