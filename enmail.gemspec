# coding: utf-8

# (c) Copyright 2018 Ribose Inc.
#

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "enmail/version"
require "enmail/dependency_constraints"

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

  # There is no reason for 2.6.4 to be a minimum supported version of Mail,
  # except for that this gem was never tested against older versions.
  # Mail 2.6.4 has been released on March 23, 2016, hence should be considered
  # old enough.  Nevertheless, pull requests which extend compatibility will be
  # accepted.
  #
  # Version 2.7.0 has been blacklisted due to some bug (not sure which one
  # exactly) in that version, which is fatal for EnMail.  That bug has been
  # fixed in 2.7.1.
  spec.add_dependency "mail", "~> 2.6", ">= 2.6.4", "!= 2.7.0"

  spec.add_development_dependency "bundler", ">= 1.14", "< 3.0"
  spec.add_development_dependency "gpgme", *EnMail::DependencyConstraints::GPGME
  spec.add_development_dependency "pry", ">= 0.10.3", "< 0.12"
  spec.add_development_dependency "rake", ">= 10", "< 13"
  spec.add_development_dependency "rnp", *EnMail::DependencyConstraints::RNP
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-pgp_matchers", "~> 0.2.0"
end
