# (c) Copyright 2018 Ribose Inc.
#

require "spec_helper"

RSpec.describe "Encrypting with GPGME" do
  include_context "example emails"
  include_context "expectations for example emails"
  include_context "gpgme spec helpers"

  specify "a non-multipart text-only message" do
    mail = simple_mail

    EnMail.protect :encrypt, mail, adapter: adapter_class
    mail.deliver
    common_message_expectations(mail)
    pgp_encrypted_part_expectations(mail)
    decrypted_part_expectations_for_simple_mail(decrypt_mail(mail))
  end

  specify "a non-multipart HTML message" do
    mail = simple_html_mail

    EnMail.protect :encrypt, mail, adapter: adapter_class
    mail.deliver
    common_message_expectations(mail)
    pgp_encrypted_part_expectations(mail)
    decrypted_part_expectations_for_simple_html_mail(decrypt_mail(mail))
  end

  specify "a multipart text+HTML message" do
    mail = text_html_mail

    EnMail.protect :encrypt, mail, adapter: adapter_class
    mail.deliver
    common_message_expectations(mail)
    pgp_encrypted_part_expectations(mail)
    decrypted_part_expectations_for_text_html_mail(decrypt_mail(mail))
  end

  specify "a multipart message with binary attachments" do
    mail = text_jpeg_mail

    EnMail.protect :encrypt, mail, adapter: adapter_class
    mail.deliver
    common_message_expectations(mail)
    pgp_encrypted_part_expectations(mail)
    decrypted_part_expectations_for_text_jpeg_mail(decrypt_mail(mail))
  end
end
