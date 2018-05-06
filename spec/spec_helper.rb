require "bundler/setup"
require "enmail"
require "pry"

Dir[File.expand_path 'support/**/*.rb', __dir__].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # config.action_mailer.delivery_method = :test
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
