require "bundler/setup"
require "mail/secure"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # config.action_mailer.delivery_method = :test
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Mail.defaults do
  delivery_method :test
end
