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

  describe "::resolve_adapter_name" do
    subject { described_class.method(:resolve_adapter_name) }

    specify "if class is given, returns that class" do
      some_class = Class.new
      expect(subject.(some_class)).to be(some_class)
    end

    specify "if symbol of adapter name is given, returns that adapter" do
      expect(subject.(:rnp)).to be(::EnMail::Adapters::RNP)
      expect(subject.(:gpgme)).to be(::EnMail::Adapters::GPGME)
    end

    specify "if string of adapter name is given, returns that adapter" do
      expect(subject.("rnp")).to be(::EnMail::Adapters::RNP)
      expect(subject.("gpgme")).to be(::EnMail::Adapters::GPGME)
    end

    specify "if given argument cannot be resolved, raises an ArgumentError" do
      expect { subject.("unknown") }.to raise_error(ArgumentError)
      expect { subject.(:unknown) }.to raise_error(ArgumentError)
      expect { subject.(nil) }.to raise_error(ArgumentError)
      expect { subject.(1) }.to raise_error(ArgumentError)
    end
  end
end
