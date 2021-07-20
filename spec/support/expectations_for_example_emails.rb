# (c) Copyright 2018 Ribose Inc.
#

# No kidding that four lines long methods without any control flow constructs
# are "too long".  Yes, there are plenty of method calls, and that maxes
# out Branch score in "Assignment Branch Condition" metrics, but it's all
# natural, readable, and clean.  Any attempt to "fix" that would rather do mess
# than improve anything.  And actually, only method bodies are measured,
# hence if following methods were inlined into some RSpec examples, no style
# offence would be reported, which is ridiculous.
# rubocop:disable Metrics/AbcSize
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

  def pgp_signed_part_expectations(message_or_part, expected_signer: mail_from,
    expected_micalg: default_expected_micalg)

    expect(message_or_part.mime_type).to eq("multipart/signed")
    expect(message_or_part.content_type_parameters).to include(
      "micalg" => expected_micalg,
      "protocol" => "application/pgp-signature",
    )
    expect(message_or_part.parts.size).to eq(2)
    expect(message_or_part.parts[1].mime_type)
      .to eq("application/pgp-signature")
    expect(message_or_part.parts[1].content_type_parameters).to be_empty

    expect(message_or_part.parts[1].body.decoded)
      .to be_a_valid_pgp_signature_of(message_or_part.parts[0].encoded)
      .signed_by(expected_signer)
  end

  def pgp_encrypted_part_expectations(message_or_part)
    expect(message_or_part.mime_type).to eq("multipart/encrypted")
    expect(message_or_part.content_type_parameters).to include(
      "protocol" => "application/pgp-encrypted",
    )
    expect(message_or_part.parts.size).to eq(2)
    expect(message_or_part.parts[0].mime_type)
      .to eq("application/pgp-encrypted")
    expect(message_or_part.parts[0].content_type_parameters).to be_empty
    expect(message_or_part.parts[0].body.encoded).to eq("Version: 1")

    expect(message_or_part.parts[1].body.decoded)
      .to be_a_pgp_encrypted_message
      .encrypted_for(mail_to)
  end

  def pgp_signed_and_encrypted_part_expectations(message_or_part,
    expected_signer: mail_from)
    # General encrypted message expectations do apply as it is generally
    # an encrypted message, it just has some signatures added.
    pgp_encrypted_part_expectations(message_or_part)

    expect(message_or_part.parts[1].body.decoded)
      .to be_a_pgp_encrypted_message
      .signed_by(expected_signer)
  end

  def resilent_transport_encoding_expectations(message_or_part)
    expect(
      message_or_part.content_transfer_encoding
    ).to eq("base64") | eq("quoted-printable")
  end
end
# rubocop:enable Metrics/AbcSize
