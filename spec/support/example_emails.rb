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
end
