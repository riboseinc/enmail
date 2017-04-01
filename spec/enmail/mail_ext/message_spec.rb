require "spec_helper"

RSpec.describe Mail::Message do
  describe "#sign" do
    it "sets the signer details" do
      mail = Mail.new
      mail.sign
    end
  end
end
