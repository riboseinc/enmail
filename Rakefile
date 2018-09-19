# (c) Copyright 2018 Ribose Inc.
#

require "bundler/gem_tasks"
require "rspec/core/rake_task"

require "tempfile"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :pgp_keys do
  def init_homedir_if_missing
    return if Dir.exists?(TMP_PGP_HOME)

    FileUtils.mkdir_p(TMP_PGP_HOME)

    File.write(File.join(TMP_PGP_HOME, "gpg.conf"), <<~GPGCONF)
      personal-digest-preferences SHA512
    GPGCONF

    File.write(File.join(TMP_PGP_HOME, "gpg-agent.conf"), <<~AGENTCONF)
      default-cache-ttl 0
    AGENTCONF
  end

  def execute_gpg(*options)
    init_homedir_if_missing
    common_options = ["--no-permission-warning", "--homedir", TMP_PGP_HOME]
    cmd = ["gpg", *common_options, *options]
    system(*cmd)
  end

  # Available parameters for unattended GPG key generation are described here:
  # https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html
  def generate_pgp_keys(key_params)
    Tempfile.create("gnupg-key-params") do |key_params_file|
      key_params_file.write(key_params)
      key_params_file.close
      execute_gpg("--batch", "--gen-key", in: key_params_file.path)
    end
  end

  desc "Lists keys in tmp/pgp_home"
  task :list => :prepare do
    execute_gpg "--list-keys"
  end

  desc "Stops all GPG daemons, and deletes tmp/pgp_home"
  task :clear => :prepare do
    if File.exists?(TMP_PGP_HOME)
      system "gpgconf", "--homedir", TMP_PGP_HOME, "--kill", "all"
      FileUtils.remove_entry_secure TMP_PGP_HOME
    end
  end

  desc "Clears tmp/pgp_home, and generates new set of keys"
  task :regenerate => %i[clear generate]

  desc "Generates keys in tmp/pgp_home"
  task :generate => :prepare do
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

task :prepare do
  require_relative "./spec/support/0_tmp_pgp_home"
end
