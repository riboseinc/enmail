require "bundler/gem_tasks"
require "rspec/core/rake_task"

require "tempfile"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :pgp_keys do
  def execute_gpg(*options)
    common_options = ["--no-permission-warning", "--homedir", TMP_GPGME_HOME]
    cmd = ["gpg", *common_options, *options]
    system(*cmd)
  end

  # Available parameters for unattended GPG key generation are described here:
  # https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html
  def generate_pgp_keys(key_params)
    Tempfile.create do |key_params_file|
      key_params_file.write(key_params)
      key_params_file.close
      execute_gpg("--batch", "--gen-key", in: key_params_file.path)
    end
  end

  desc "Lists keys in tmp/pgp_home"
  task :list => :init_gpgme do
    execute_gpg "--list-keys"
  end

  desc "Generates keys in tmp/pgp_home"
  task :generate => :init_gpgme do
    # Key pairs without password
    generate_pgp_keys(<<~KEY_PARAMS)
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
    KEY_PARAMS

    generate_pgp_keys(<<~KEY_PARAMS)
      %no-protection
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
    KEY_PARAMS

    generate_pgp_keys(<<~KEY_PARAMS)
      %no-protection
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
    KEY_PARAMS

    # Password-protected key pairs
    generate_pgp_keys(<<~KEY_PARAMS)
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
    KEY_PARAMS
  end
end

task :init_gpgme do
  require "gpgme"
  require_relative "./spec/support/gpgme_setup"
end
