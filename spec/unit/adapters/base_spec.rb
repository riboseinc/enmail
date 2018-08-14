# (c) Copyright 2018 Ribose Inc.
#

require "spec_helper"

RSpec.describe EnMail::Adapters::Base do
  describe "::new" do
    it "sets adapter options according to Hash passed as the only argument " do
      options = { very: :custom }
      instance = described_class.new(options)
      expect(instance.options).to eq(options)
    end
  end
end
