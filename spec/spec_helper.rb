# (c) Copyright 2018 Ribose Inc.
#

require "simplecov"
SimpleCov.start

if ENV.key?("CI")
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "bundler/setup"
require "enmail"
require "pry"

require "rspec/pgp_matchers"

Dir[File.expand_path "support/**/*.rb", __dir__].sort.each { |f| require f }


module RunnerOverride
        def run_command(gpg_cmd)
          out_file = Tempfile.create("rspec-gpg-runner-out")
          err_file = Tempfile.create("rspec-gpg-runner-err")

          homedir_path = Shellwords.escape(RSpec::PGPMatchers.homedir)
          out_file_path = Shellwords.escape(out_file.path)
          err_file_path = Shellwords.escape(err_file.path)

          env = { "LC_ALL" => "C" } # Gettext English locale
          opts = {out: out_file_path, err: err_file_path}

          system(env, <<~SH, **opts)
            gpg \
            --homedir #{homedir_path} \
            --no-permission-warning \
            #{gpg_cmd}
          SH

          [out_file.read, err_file.read, $?]
        ensure
          File.unlink(*[out_file, err_file].compact)
        end
end

module RSpec
  module PGPMatchers
    module GPGRunner
      class << self
        prepend ::RunnerOverride
      end
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # config.action_mailer.delivery_method = :test
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
