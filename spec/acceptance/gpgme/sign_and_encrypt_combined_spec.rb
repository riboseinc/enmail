require "spec_helper"

RSpec.describe "Signing and encrypting in combined fashion with GPGME" do
  include_context "example emails"
  include_context "expectations for example emails"
  include_context "gpgme spec helpers"

  specify "a non-multipart text-only message" do
    mail = simple_mail

    EnMail.protect :sign_and_encrypt_combined, mail, adapter: adapter_class
    mail.deliver
    common_message_expectations(mail)
    pgp_signed_and_encrypted_part_expectations(mail)
    decrypted_mail = decrypt_mail(mail)
    decrypted_part_expectations_for_simple_mail(decrypted_mail)
    resilent_transport_encoding_expectations(decrypted_mail)
  end

  specify "a non-multipart HTML message" do
    mail = simple_html_mail

    EnMail.protect :sign_and_encrypt_combined, mail, adapter: adapter_class
    mail.deliver
    common_message_expectations(mail)
    pgp_signed_and_encrypted_part_expectations(mail)
    decrypted_mail = decrypt_mail(mail)
    decrypted_part_expectations_for_simple_html_mail(decrypted_mail)
    resilent_transport_encoding_expectations(decrypted_mail)
  end

  specify "a multipart text+HTML message" do
    mail = text_html_mail

    EnMail.protect :sign_and_encrypt_combined, mail, adapter: adapter_class
    mail.deliver
    common_message_expectations(mail)
    pgp_signed_and_encrypted_part_expectations(mail)
    decrypted_mail = decrypt_mail(mail)
    decrypted_part_expectations_for_text_html_mail(decrypted_mail)
    resilent_transport_encoding_expectations(decrypted_mail.parts[0])
    resilent_transport_encoding_expectations(decrypted_mail.parts[1])
  end

  specify "a multipart message with binary attachments" do
    mail = text_jpeg_mail

    EnMail.protect :sign_and_encrypt_combined, mail, adapter: adapter_class
    mail.deliver
    common_message_expectations(mail)
    pgp_signed_and_encrypted_part_expectations(mail)
    decrypted_mail = decrypt_mail(mail)
    decrypted_part_expectations_for_text_jpeg_mail(decrypted_mail)
    resilent_transport_encoding_expectations(decrypted_mail.parts[0])
    resilent_transport_encoding_expectations(decrypted_mail.parts[1])
  end
end
