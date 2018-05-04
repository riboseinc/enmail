shared_context "expectations for example emails" do
  def decrypted_part_expectations_for_simple_mail(message_or_part)
    expect(message_or_part.mime_type).to eq("text/plain")
    expect(message_or_part.body.decoded).to eq(mail_text)
  end

  def decrypted_part_expectations_for_simple_html_mail(message_or_part)
    expect(message_or_part.mime_type).to eq("text/html")
    expect(message_or_part.body.decoded).to eq(mail_html)
  end

  def decrypted_part_expectations_for_text_html_mail(message_or_part)
    expect(message_or_part.parts[0].mime_type).to eq("text/plain")
    expect(message_or_part.parts[0].body.decoded).to eq(mail_text)
    expect(message_or_part.parts[1].mime_type).to eq("text/html")
    expect(message_or_part.parts[1].body.decoded).to eq(mail_html)
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

  def pgp_signed_part_expectations(message_or_part, expected_signer: mail_from)
    expect(message_or_part.mime_type).to eq("multipart/signed")
    expect(message_or_part.content_type_parameters).to include(
      "micalg" => "pgp-sha1",
      "protocol" => "application/pgp-signature",
    )
    expect(message_or_part.parts.size).to eq(2)
    expect(message_or_part.parts[1].mime_type).
      to eq("application/pgp-signature")
    expect(message_or_part.parts[1].content_type_parameters).to be_empty

    expect(message_or_part.parts[1].body.decoded).
      to be_a_valid_pgp_signature_of(message_or_part.parts[0].encoded).
      signed_by(expected_signer)
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
end