require "spec_helper"

RSpec.describe "Sending without protection (unaltered by EnMail)" do
  include_context "example emails"

  specify "a non-multipart text-only message" do
    mail = simple_mail

    mail.deliver
    expect(mail.from).to contain_exactly(mail_from)
    expect(mail.to).to contain_exactly(mail_to)
    expect(mail.mime_type).to eq("text/plain")
    expect(mail.body.decoded).to eq(mail_text)
  end

  specify "a non-multipart HTML message" do
    mail = simple_html_mail

    mail.deliver
    expect(mail.from).to contain_exactly(mail_from)
    expect(mail.to).to contain_exactly(mail_to)
    expect(mail.mime_type).to eq("text/html")
    expect(mail.body.decoded).to eq(mail_html)
  end

  specify "a multipart text+HTML message" do
    mail = text_html_mail

    mail.deliver
    expect(mail.from).to contain_exactly(mail_from)
    expect(mail.to).to contain_exactly(mail_to)
    expect(mail.body.raw_source).to be_empty
    expect(mail.parts[0].mime_type).to eq("text/plain")
    expect(mail.parts[0].body.decoded).to eq(mail_text)
    expect(mail.parts[1].mime_type).to eq("text/html")
    expect(mail.parts[1].body.decoded).to eq(mail_html)
  end

  specify "a multipart message with binary attachments" do
    mail = text_jpeg_mail

    mail.deliver
    expect(mail.from).to contain_exactly(mail_from)
    expect(mail.to).to contain_exactly(mail_to)
    expect(mail.body.raw_source).to be_empty
    expect(mail.parts[0].mime_type).to eq("text/plain")
    expect(mail.parts[0].body.decoded).to eq(mail_text)
    expect(mail.parts[1].mime_type).to eq("image/jpeg")
    expect(mail.parts[1].body.decoded).to eq(SMALLEST_JPEG)
  end
end
