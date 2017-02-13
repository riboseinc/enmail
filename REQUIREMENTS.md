Ruby mail extension for sending/receiving secure mail

# TODO: JL add interceptor


OpenPGP (RFC 4880) and S/MIME (RFC 5751) are two methods for secure mail
delivery today.

Currently there is no existing mail gem extension (Ruby Gem) that allows
switching between the methods and are usually not well structured.

This work is to complete implementation of the mail-secure gem by
leveraging existing OpenPGP and S/MIME mail extension code to allow
secure email sending via either standard (or a combination of both).

The mail-secure gem uses the concept of "adapters" to support different
underlying libraries. For OpenPGP, there are two existing
implementations: GnuPG and NetPGP. For S/MIME the default Ruby Openssl
implementation should be used.

Implementations to support:
* OpenPGP
  * NetPGP
  * GnuPG
* S/MIME
  * OpenSSL

This gem allows you to select different OpenPGP implementations
including NetPGP and GnuPG as different OpenPGP adapters, and also
S/MIME.

References:
* https://github.com/jkraemer/mail-gpg
* https://github.com/bluerail/mr_smime

Example code:


```ruby
message = Mail.new
message.decrypt
signed_mail = m.sign(signature)
encrypted_mail = m.encrypt(identity)
signed_email.signature_valid?
signed_email.signature_valid?
signed_email.secure?
signed_email.pgp? => :inline, :mime, nil
signed_email.pgp_inline?
signed_email.pgp_mime?
encrypted_email.secure? => "OpenPGP RFC 4880"
signed_email.smime?
Mail::Secure::OpenPGP.verify_signature?(signed_email)

```

```ruby

Mail::Secure.configuration = {
  method: :openpgp,
  implementation: :netpgp,
  key: "ASCII-ARMORED-PGP-KEY"
# or
  key_id: "key-id",
  keyring: "keyring-location",
# or infer from GNUPGHOME
  key_id: "key-id"
}

Mail.new do
  to 'jane@doe.net'
  from 'john@doe.net'
  subject 'gpg test'
  body "encrypt me!"
  add_file "some_attachment.zip"

  # using default configuration
  secure encrypt: true, encrypt_for: Key.find("mike@kite.com")

  secure sign: true
  secure encrypt: true, encrypt_for: PrivateKey.find("myself")
  secure sign: true, sign_as: PrivateKey.find("myself")
  secure encrypt: true
  secure encrypt: true, passphrase: "secret"
  secure encrypt: true, passphrase_callback: ->(...) {}

  # encrypt and sign message with sender's private key, using the given
  # passphrase to decrypt the key
  gpg encrypt: true, sign: true, password: 'secret'

  # encrypt and sign message using a different key
  gpg encrypt: true, sign_as: 'joe@otherdomain.com', password: 'secret'


  # encrypt and sign message and use a callback function to provide the
  # passphrase.
  gpg encrypt: true, sign_as: 'joe@otherdomain.com',
      passphrase_callback: ->(obj, uid_hint, passphrase_info, prev_was_bad, fd){puts "Enter passphrase for #{passphrase_info}: "; (IO.for_fd(fd, 'w') << readline.chomp).flush }

end
---------


johns_key = <<-END
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.12 (GNU/Linux)

mQGiBEk39msRBADw1ExmrLD1OUMdfvA7cnVVYTC7CyqfNvHUVuuBDhV7azs
....
END

Mail.new do
  to 'john@foo.bar'
  gpg encrypt: true, keys: { 'john@foo.bar' => johns_key }
end

----------------
passphrase

mail = Mail.first
mail.subject # subject is never encrypted
if mail.encrypted?
  # decrypt using your private key, protected by the given passphrase
  plaintext_mail = mail.decrypt(:password => 'abc')
  # the plaintext_mail, is a full Mail::Message object, just decrypted
end

-------------
sign

Mail.new do
  to 'jane@doe.net'
  gpg sign: true
end.deliver 

---------------
verify signature

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

