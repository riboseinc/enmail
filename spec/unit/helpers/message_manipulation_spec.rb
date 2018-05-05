require "spec_helper"

RSpec.describe EnMail::Helpers::MessageManipulation do
  let(:adapter) { EnMail::Adapters::Base.new(options).extend(described_class) }
  let(:options) { {} }
end
