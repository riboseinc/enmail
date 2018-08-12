RSpec.configure do |config|
  config.before(:example) do |example|
    requires = [*example.metadata[:requires]]
    requires.select! { |rq| ENV["TEST_WITHOUT_#{rq.to_s.upcase}"] }

    unless requires.empty?
      skip "This test requires presence of #{requires[0]} optional dependency"
    end
  end
end
