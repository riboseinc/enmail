shared_context "example emails" do
  let(:mail_from) { "cato.elder@example.test" }
  let(:mail_to) { "senate@example.test" }
  let(:mail_subject) { "It is very important" }
  let(:mail_text) { "Carthage must be destroyed!" }
  let(:mail_html) { "<strong>#{mail_text}</strong>" }

  let(:simple_mail) do
    m = Mail.new
    m.from = mail_from
    m.to = mail_to
    m.subject = mail_subject
    m.headers["custom"] = "custom-header-value"
    m.body = mail_text
    m
  end

  def decrypted_part_expectations_for_simple_mail(message_or_part)
    expect(message_or_part.mime_type).to eq("text/plain")
    expect(message_or_part.body.decoded).to eq(mail_text)
  end

  let(:simple_html_mail) do
    m = Mail.new
    m.from = mail_from
    m.to = mail_to
    m.subject = mail_subject
    m.headers["custom"] = "custom-header-value"
    m.body = mail_html
    m.content_type = "text/html"
    m
  end

  def decrypted_part_expectations_for_simple_html_mail(message_or_part)
    expect(message_or_part.mime_type).to eq("text/html")
    expect(message_or_part.body.decoded).to eq(mail_html)
  end

  let(:text_html_mail) do
    m = Mail.new
    m.from = mail_from
    m.to = mail_to
    m.subject = mail_subject
    m.headers["custom"] = "custom-header-value"
    m.text_part = mail_text
    m.html_part = mail_html
    m
  end

  def decrypted_part_expectations_for_text_html_mail(message_or_part)
    expect(message_or_part.parts[0].mime_type).to eq("text/plain")
    expect(message_or_part.parts[0].body.decoded).to eq(mail_text)
    expect(message_or_part.parts[1].mime_type).to eq("text/html")
    expect(message_or_part.parts[1].body.decoded).to eq(mail_html)
  end

  let(:text_jpeg_mail) do
    m = Mail.new
    m.from = mail_from
    m.to = mail_to
    m.subject = mail_subject
    m.headers["custom"] = "custom-header-value"
    m.body = mail_text
    m.add_file filename: "pic.jpg", content: SMALLEST_JPEG
    m
  end

  def decrypted_part_expectations_for_text_jpeg_mail(message_or_part)
    expect(message_or_part.parts[0].mime_type).to eq("text/plain")
    expect(message_or_part.parts[0].body.decoded).to eq(mail_text)
    expect(message_or_part.parts[1].mime_type).to eq("image/jpeg")
    expect(message_or_part.parts[1].body.decoded).to eq(SMALLEST_JPEG)
  end

  def common_message_expectations(message)
    expect(message.from).to contain_exactly(mail_from)
    expect(message.to).to contain_exactly(mail_to)
    expect(message.subject).to eq(mail_subject)
  end
end
