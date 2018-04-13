require "spec_helper"

RSpec.describe EnMail::Adapters::GPGME do
  let(:adapter) { described_class.new(options) }
  let(:options) { {} }

  describe "#sign" do
    subject { described_class.instance_method(:sign) }
    pending "write tests"
  end
end
