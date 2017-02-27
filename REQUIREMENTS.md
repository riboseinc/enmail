# Ruby mail extension for sending/receiving secure mail

[//]: # (TODO: JL add interceptor)

OpenPGP [RFC 4880] and S/MIME [RFC 5751] are two methods for secure mail
delivery today.

Currently there is no existing mail gem extension (Ruby Gem) that allows
switching between the methods and are usually not well structured.

This work is to complete implementation of the mail-secure gem by
leveraging existing OpenPGP and S/MIME mail extension code to allow
secure email sending via either standard (or a combination of both).

The mail-secure gem uses the concept of "adapters" to support different
underlying libraries.

* For OpenPGP, there are two existing implementations: GnuPG and NetPGP.
* For S/MIME, the default Ruby OpenSSL implementation should be used.


## Implementations to support:

* OpenPGP
  * NetPGP
  * GnuPG
* S/MIME
  * OpenSSL

This gem allows you to select different OpenPGP implementations
including NetPGP and GnuPG as different OpenPGP adapters, and also
S/MIME.

## References and notes

* <https://github.com/jkraemer/mail-gpg>
* <https://github.com/bluerail/mr_smime>

The `mail-gpg` gem hacks the default `mail` gem Deliverer to ensure the
OpenPGP encryption/signing step is done at the last. This is extremely
dirty and fragile.

The `mr_smime` gem uses an interceptor hook (supplied by the `mail` gem)
to encrypt/sign the email. The catch is the `mail` gem supports
multiple interceptors (like Rack middlewares) so there is no guarantee
that it is the last interceptor.

A better approach is to use the interceptor pattern, and hack the
interceptor methods in `mail` to force a particular interceptor (the one
to implement) to be at the very end.

Technically, this resulting implementation could allow usage of OpenPGP
to sign/encrypt a message, then use S/MIME to sign (and/or encrypt) the
OpenPGP-encoded message at the same time.


## OpenPGP Example code

```ruby
message = Mail.new
message.decrypt

signed_mail    = message.sign(key)
encrypted_mail = message.encrypt(identity)

signed_email.signature_valid? # => true, false
signed_email.secure?          # => true, false
signed_email.pgp              # => :inline, :mime, nil
signed_email.pgp?             # => true, false
signed_email.pgp_inline?      # => true, false
signed_email.pgp_mime?        # => true, false
encrypted_email.secure        # => "OpenPGP RFC 4880", nil
encrypted_email.secure?       # => true, false
signed_email.smime?           # => true, false

Mail::Secure::OpenPGP.signature_valid?(signed_email) # => true, false
```

## OpenPGP Configuration

```ruby
Mail::Secure.configuration = {
  method:         :openpgp,
  implementation: :netpgp, # :gpgme

  # Specify PGP key in 3 ways.
  # Only providing the key:
  key:     "ASCII-ARMORED-PGP-KEY",
  key:     "non-armored-raw-bytes-pgp-key",
  # or:
  key_id:  "key-id",
  keyring: "/Users/whoami/keyring-location",
  # or infer "keyring" from GNUPGHOME:
  key_id:  "key-id",
}

```

### Sample mail object

```ruby
Mail.new do
  to       'jane@doe.net'
  from     'john@doe.net'
  subject  'gpg test'
  body     "encrypt me!"
  add_file "some_attachment.zip"

  # Using default :method configuration:
  secure encrypt: true, encrypt_for: Key.find("mike@kite.com")

  # #secure's first argument is optional: :openpgp | :smime
  # If missing, then use the default configuration.
  secure :openpgp, encrypt: true, encrypt_for: Key.find("mike@kite.com")
  secure :smime,   encrypt: true, encrypt_for: Key.find("mike@kite.com")

  # #secure as a long-hand:
  secure :openpgp, sign: true
  secure :openpgp, encrypt: true, encrypt_for: PrivateKey.find("myself")
  secure :openpgp, sign: true, sign_as: PrivateKey.find("myself")
  secure :openpgp, encrypt: true
  secure :openpgp, encrypt: true, passphrase: "secret"
  secure :openpgp, encrypt: true, passphrase_callback: ->(...) {}

  # #openpgp or #smime as short-hand:
  smime sign: true
  smime encrypt: true, encrypt_for: PrivateKey.find("myself")
  smime sign: true, sign_as: PrivateKey.find("myself")
  openpgp encrypt: true
  openpgp encrypt: true, passphrase: "secret"
  openpgp encrypt: true, passphrase_callback: ->(...) {}

  # encrypt and sign message with sender's private key, using the given
  # passphrase to decrypt the key
  openpgp encrypt: true, sign: true, password: 'secret'

  # encrypt and sign message using a different key
  openpgp encrypt: true, sign_as: 'joe@otherdomain.com', password: 'secret'


  # encrypt and sign message and use a callback function to provide the
  # passphrase.
  openpgp encrypt: true, sign_as: 'joe@otherdomain.com',
    passphrase_callback: ->(obj, uid_hint, passphrase_info, prev_was_bad, fd) {
      puts "Enter passphrase for #{passphrase_info}: "
      (IO.for_fd(fd, 'w') << readline.chomp).flush
    }
end.deliver

```

#### Encrypt mail using OpenPGP public key directly

```ruby
johns_key = <<-END
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG vX.X.XX (GNU/Linux)

mQGiBEk39msRBADw1ExmrLD1OUMdfvA7cnVVYTC7CyqfNvHUVuuBDhV7azs
....
END

Mail.new do
  to 'john@foo.bar'
  gpg encrypt: true, keys: { 'john@foo.bar' => johns_key }
end

```

### Decrypting mail using passphrase

```ruby

mail = Mail.first
mail.subject # subject is never encrypted
if mail.encrypted?
  # decrypt using your private key, protected by the given passphrase
  plaintext_mail = mail.decrypt(password: 'abc')
  # the plaintext_mail, is a full Mail::Message object, just decrypted
end

```

### Signing mail (simplest case)

```ruby


Mail.new do
  to 'jane@doe.net'
  gpg sign: true
end.deliver

```

### Verifying signature

```ruby

mail = Mail.first
if !mail.encrypted? && mail.signed?
  verified = mail.verify
  puts "signature(s) valid: #{verified.signature_valid?}"
  puts "message signed by: #{verified.signatures.map{|sig|sig.from}.join("\n")}"
end


if mail.encrypted?
  decrypted = mail.decrypt(verify: true, password: 's3cr3t')
  puts "signature(s) valid: #{decrypted.signature_valid?}"
  puts "message signed by: #{decrypted.signatures.map{|sig|sig.from}.join("\n")}"
end

```
