# (c) Copyright 2018 Ribose Inc.
#

require "spec_helper"

RSpec.describe "Signing with GPGME", requires: :gpgme do
  include_context "example emails"
  include_context "expectations for example emails"
  include_context "gpgme spec helpers"

  specify "a non-multipart text-only message" do
    mail = simple_mail

    EnMail.protect :sign, mail, adapter: adapter_class
    mail.deliver
    common_message_expectations(mail)
    pgp_signed_part_expectations(mail)
    decrypted_part_expectations_for_simple_mail(mail.parts[0])
    resilent_transport_encoding_expectations(mail.parts[0])
  end

  specify "a non-multipart HTML message" do
    mail = simple_html_mail

    EnMail.protect :sign, mail, adapter: adapter_class
    mail.deliver
    common_message_expectations(mail)
    pgp_signed_part_expectations(mail)
    decrypted_part_expectations_for_simple_html_mail(mail.parts[0])
    resilent_transport_encoding_expectations(mail.parts[0])
  end

  specify "a multipart text+HTML message" do
    mail = text_html_mail

    EnMail.protect :sign, mail, adapter: adapter_class
    mail.deliver
    common_message_expectations(mail)
    pgp_signed_part_expectations(mail)
    decrypted_part_expectations_for_text_html_mail(mail.parts[0])
    resilent_transport_encoding_expectations(mail.parts[0].parts[0])
    resilent_transport_encoding_expectations(mail.parts[0].parts[1])
  end

  specify "a multipart message with binary attachments" do
    mail = text_jpeg_mail

    EnMail.protect :sign, mail, adapter: adapter_class
    mail.deliver
    common_message_expectations(mail)
    pgp_signed_part_expectations(mail)
    decrypted_part_expectations_for_text_jpeg_mail(mail.parts[0])
    resilent_transport_encoding_expectations(mail.parts[0].parts[0])
    resilent_transport_encoding_expectations(mail.parts[0].parts[1])
  end

  specify "with specific signer key" do
    mail = simple_mail
    signer = "whatever@example.test"

    EnMail.protect :sign, mail, adapter: adapter_class, signer: signer
    mail.deliver
    common_message_expectations(mail)
    pgp_signed_part_expectations(mail, expected_signer: signer)
    decrypted_part_expectations_for_simple_mail(mail.parts[0])
  end

  specify "with a password-protected signer key" do
    mail = simple_mail
    signer = "cato.elder+pwd@example.test"

    EnMail.protect :sign, mail, adapter: adapter_class, signer: signer,
                                key_password: "1234"
    mail.deliver
    common_message_expectations(mail)
    pgp_signed_part_expectations(mail, expected_signer: signer)
    decrypted_part_expectations_for_simple_mail(mail.parts[0])
  end
end
