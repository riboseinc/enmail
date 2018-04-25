require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

# Available parameters for unattended GPG key generation are described here:
# https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html
task :generate_gpg_keys => :init_gpgme do
  ::GPGME::Ctx.new.genkey(<<~EOS)
    <GnupgKeyParms format="internal">
    %no-protection
    Key-Type: DSA
    Key-Length: 2048
    Subkey-Type: ELG-E
    Subkey-Length: 2048
    Name-Real: Cato Elder
    Name-Email: cato.elder@example.test
    Name-Comment: Without passphrase
    Expire-Date: 0
    </GnupgKeyParms>
  EOS
end

task :init_gpgme do
  require "gpgme"
  require_relative "./spec/support/gpgme_setup"
end
