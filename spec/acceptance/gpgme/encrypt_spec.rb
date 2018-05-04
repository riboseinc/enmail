require "spec_helper"

RSpec.describe "Encrypting with GPGME" do
  include_context "example emails"

  specify "a non-multipart text-only message" do
    mail = simple_mail

    EnMail.protect :encrypt, mail
    mail.deliver
    common_message_expectations(mail)
    pgp_encrypted_part_expectations(mail)
    decrypted_part_expectations_for_simple_mail(decrypt_mail(mail))
  end

  specify "a non-multipart HTML message" do
    mail = simple_html_mail

    EnMail.protect :encrypt, mail
    mail.deliver
    common_message_expectations(mail)
    pgp_encrypted_part_expectations(mail)
    decrypted_part_expectations_for_simple_html_mail(decrypt_mail(mail))
  end

  specify "a multipart text+HTML message" do
    mail = text_html_mail

    EnMail.protect :encrypt, mail
    mail.deliver
    common_message_expectations(mail)
    pgp_encrypted_part_expectations(mail)
    decrypted_part_expectations_for_text_html_mail(decrypt_mail(mail))
  end

  specify "a multipart message with binary attachments" do
    mail = text_jpeg_mail

    EnMail.protect :encrypt, mail
    mail.deliver
    common_message_expectations(mail)
    pgp_encrypted_part_expectations(mail)
    decrypted_part_expectations_for_text_jpeg_mail(decrypt_mail(mail))
  end

  def pgp_encrypted_part_expectations(message_or_part)
    expect(message_or_part.mime_type).to eq("multipart/encrypted")
    expect(message_or_part.content_type_parameters).to include(
      "protocol" => "application/pgp-encrypted",
    )
    expect(message_or_part.parts.size).to eq(2)
    expect(message_or_part.parts[0].mime_type).
      to eq("application/pgp-encrypted")
    expect(message_or_part.parts[0].content_type_parameters).to be_empty
    expect(message_or_part.parts[0].body.encoded).to eq("Version: 1")

    expect(message_or_part.parts[1].body.decoded).
      to be_a_pgp_encrypted_message.
      encrypted_for(mail_to)
  end

  def decrypt_mail(message)
    encrypted_message = message.parts[1].body.decoded
    decrypted_raw_message = GPGME::Crypto.new.decrypt(encrypted_message)
    Mail::Part.new(decrypted_raw_message)
  end
end
