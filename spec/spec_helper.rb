require "bundler/setup"
require "enmail"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # config.action_mailer.delivery_method = :test
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Configure EnMail
  #
  config.before(:all) do
    EnMail.configure do |enmail_config|
      enmail_config.certificates_path =
        File.expand_path("../fixtures", __FILE__)
    end
  end
end
