# (c) Copyright 2018 Ribose Inc.
#

require "spec_helper"

RSpec.describe "Sending without protection (unaltered by EnMail)" do
  include_context "example emails"
  include_context "expectations for example emails"

  specify "a non-multipart text-only message" do
    mail = simple_mail

    mail.deliver
    common_message_expectations(mail)
    decrypted_part_expectations_for_simple_mail(mail)
  end

  specify "a non-multipart HTML message" do
    mail = simple_html_mail

    mail.deliver
    common_message_expectations(mail)
    decrypted_part_expectations_for_simple_html_mail(mail)
  end

  specify "a multipart text+HTML message" do
    mail = text_html_mail

    mail.deliver
    common_message_expectations(mail)
    decrypted_part_expectations_for_text_html_mail(mail)
  end

  specify "a multipart message with binary attachments" do
    mail = text_jpeg_mail

    mail.deliver
    common_message_expectations(mail)
    decrypted_part_expectations_for_text_jpeg_mail(mail)
  end
end
