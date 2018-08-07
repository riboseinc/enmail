require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec # rubocop:disable Style/HashSyntax

# Available parameters for unattended GPG key generation are described here:
# https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html
# rubocop:disable Style/HashSyntax
# rubocop:disable Metrics/BlockLength
task :generate_pgp_keys => :init_gpgme do
  # Key pairs without password
  ::GPGME::Ctx.new.genkey(<<~SCRIPT)
    <GnupgKeyParms format="internal">
    %no-protection
    Key-Type: RSA
    Key-Usage: sign, cert
    Key-Length: 2048
    Subkey-Type: RSA
    Subkey-Length: 2048
    Subkey-Usage: encrypt
    Name-Real: Some Arbitrary Key
    Name-Email: whatever@example.test
    Name-Comment: Without passphrase
    Expire-Date: 0
    %commit

    Key-Type: RSA
    Key-Usage: sign, cert
    Key-Length: 2048
    Subkey-Type: RSA
    Subkey-Length: 2048
    Subkey-Usage: encrypt
    Name-Real: Cato Elder
    Name-Email: cato.elder@example.test
    Name-Comment: Without passphrase
    Expire-Date: 0
    %commit

    Key-Type: RSA
    Key-Usage: sign, cert
    Key-Length: 2048
    Subkey-Type: RSA
    Subkey-Length: 2048
    Subkey-Usage: encrypt
    Name-Real: Roman Senate
    Name-Email: senate@example.test
    Name-Comment: Without passphrase
    Expire-Date: 0
    </GnupgKeyParms>
  SCRIPT

  # Password-protected key pairs
  ::GPGME::Ctx.new.genkey(<<~SCRIPT)
    <GnupgKeyParms format="internal">
    Key-Type: RSA
    Key-Usage: sign, cert
    Key-Length: 2048
    Subkey-Type: RSA
    Subkey-Length: 2048
    Subkey-Usage: encrypt
    Name-Real: Cato Elder
    Name-Email: cato.elder+pwd@example.test
    Name-Comment: Password-protected
    Expire-Date: 0
    Passphrase: 1234
    </GnupgKeyParms>
  SCRIPT
end
# rubocop:enable Style/HashSyntax
# rubocop:enable Metrics/BlockLength

task :init_gpgme do
  require "gpgme"
  require_relative "./spec/support/gpgme_setup"
end
