# coding: utf-8

# (c) Copyright 2018 Ribose Inc.
#

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "enmail/version"

Gem::Specification.new do |spec|
  spec.name          = "enmail"
  spec.version       = EnMail::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "Encrypted Email in Ruby"
  spec.description   = "Encrypted Email in Ruby"
  spec.homepage      = "https://github.com/riboseinc/enmail"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mail", "~> 2.6.4"

  spec.add_development_dependency "bundler", ">= 1.14", "< 3.0"
  spec.add_development_dependency "gpgme", "~> 2.0"
  spec.add_development_dependency "pry", ">= 0.10.3", "< 0.12"
  spec.add_development_dependency "rake", ">= 10", "< 13"
  spec.add_development_dependency "rnp", ">= 1.0.1", "< 2"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-pgp_matchers", "~> 0.1.1"
end
