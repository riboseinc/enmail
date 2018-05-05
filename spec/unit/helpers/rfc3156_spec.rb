require "spec_helper"

RSpec.describe EnMail::Helpers::RFC3156 do
  let(:adapter) { EnMail::Adapters::Base.new(options).extend(described_class) }
  let(:options) { {} }

  include_context "example emails"
end