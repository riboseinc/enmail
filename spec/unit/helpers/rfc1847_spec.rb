# (c) Copyright 2018 Ribose Inc.
#

require "spec_helper"

RSpec.describe EnMail::Helpers::RFC1847 do
  let(:adapter) { EnMail::Adapters::Base.new(options).extend(described_class) }
  let(:options) { {} }

  include_context "example emails"

  let(:custom_sign_protocol) { "application/custom-signed" }
  let(:custom_enc_protocol) { "application/custom-encrypted" }
  let(:custom_micalg) { "custom-micalg" }

  before do
    allow(adapter).
      to receive(:sign_protocol).and_return(custom_sign_protocol)
    allow(adapter).
      to receive(:encryption_protocol).and_return(custom_enc_protocol)
    allow(adapter).
      to receive(:message_integrity_algorithm).and_return(custom_micalg)
  end

  describe "#encrypt" do
    subject { adapter.method(:encrypt) }

    let(:mail) { simple_mail }
    let(:blank_string_rx) { /\A\s*\Z/ }
    let(:msg_part_dbl) { double.as_null_object }
    let(:msg_ctrl_dbl) { double.as_null_object }
    let(:enc_part_dbl) { double.as_null_object }
    let(:enc_dummy) { "DUMMY-PGP-MESSAGE" }

    before do
      allow(adapter).to receive(:body_to_part).and_return(msg_part_dbl)
      allow(adapter).
        to receive(:build_encryption_control_part).and_return(msg_ctrl_dbl)
      allow(adapter).
        to receive(:build_encrypted_part).and_return(enc_part_dbl)
      allow(adapter).
        to receive(:encrypt_string).and_return(enc_dummy)
      allow(adapter).to receive(:restrict_encoding)
    end

    it "changes message mime type to multipart/encrypted" do
      expect { subject.(mail) }.to(
        change { mail.mime_type }.to("multipart/encrypted")
      )
    end

    it "preserves from, to, subject, date, message id, and custom headers" do
      mail.ready_to_send! # Set some default message_id
      expect { subject.(mail) }.to(
        preserve { mail.date } &
        preserve { mail.from } &
        preserve { mail.to } &
        preserve { mail.subject } &
        preserve { mail.message_id } &
        preserve { mail.headers["custom"] }
      )
    end

    it "clears the old message body" do
      expect { subject.(mail) }.
        to change { mail.body.decoded }.to(blank_string_rx)
    end

    it "adds the control information as the 1st MIME part" do
      subject.(mail)
      expect(adapter).
        to have_received(:build_encryption_control_part).with(no_args)
      expect(mail.parts[0]).to be(msg_ctrl_dbl)
    end

    it "converts the old message body to a a MIME part, and encrypts it" do
      subject.(mail)
      expect(adapter).to have_received(:body_to_part).with(mail)
      expect(adapter).to have_received(:encrypt_string).
        with(msg_part_dbl, [mail_to])
    end

    it "adds the encrypted message as the 2nd MIME part" do
      subject.(mail)
      expect(adapter).to have_received(:build_encrypted_part).with(enc_dummy)
      expect(mail.parts[1]).to be(enc_part_dbl)
    end
  end

  describe "#sign" do
    subject { adapter.method(:sign) }

    let(:mail) { simple_mail }
    let(:blank_string_rx) { /\A\s*\Z/ }
    let(:msg_part_dbl) { double.as_null_object }
    let(:sig_dbl) { double.as_null_object }
    let(:sig_dummy) { "DUMMY-PGP-SIGNATURE" }
    let(:mic_dummy) { "pgp-dummy" }

    before do
      allow(adapter).to receive(:body_to_part).and_return(msg_part_dbl)
      allow(adapter).to receive(:build_signature_part).and_return(sig_dbl)
      allow(adapter).to receive(:compute_signature).
        and_return([mic_dummy, sig_dummy])
      allow(adapter).to receive(:restrict_encoding)
    end

    it "changes message mime type to multipart/signed" do
      expect { subject.(mail) }.to(
        change { mail.mime_type }.to("multipart/signed")
      )
    end

    it "preserves from, to, subject, date, message id, and custom headers" do
      mail.ready_to_send! # Set some default message_id
      expect { subject.(mail) }.to(
        preserve { mail.date } &
        preserve { mail.from } &
        preserve { mail.to } &
        preserve { mail.subject } &
        preserve { mail.message_id } &
        preserve { mail.headers["custom"] }
      )
    end

    it "clears the old message body" do
      expect { subject.(mail) }.
        to change { mail.body.decoded }.to(blank_string_rx)
    end

    it "converts the old message body to a a MIME part, and re-appends it " +
      "to self" do
      subject.(mail)
      expect(adapter).to have_received(:body_to_part).with(mail)
      expect(mail.parts[0]).to be(msg_part_dbl)
    end

    it "computes the signature for the 1st MIME part" do
      subject.(mail)
      expect(adapter).to have_received(:compute_signature).
        with(mail.parts[0].encoded, mail_from)
    end

    it "adds the signature as the 2nd MIME part" do
      subject.(mail)
      expect(adapter).to have_received(:build_signature_part).with(sig_dummy)
      expect(mail.parts[1]).to be(sig_dbl)
    end

    it "enforces quoted-printable or base64 transport encoding for signed " +
      "part, but for nothing else" do
      subject.(mail)
      expect(adapter).to have_received(:restrict_encoding).once
      expect(adapter).to have_received(:restrict_encoding).with(msg_part_dbl)
    end
  end

  describe "#restrict_encoding" do
    subject { adapter.method(:restrict_encoding) }

    let(:ivar_name) { "@enmail_rfc18467_encoding_restrictions" }

    it "sets @enmail_rfc18467_encoding_restrictions ivar for given " +
      "non-multipart mail part" do
      part = ::Mail::Part.new
      part.content_type = "text/plain"
      expect { subject.call(part) }.to(
        change { part.instance_variable_get(ivar_name) }.to(true)
      )
    end

    it "does not change @enmail_rfc18467_encoding_restrictions ivar for " +
      "given multipart mail part" do
      part = ::Mail::Part.new
      part.content_type = "multipart/mixed"
      expect { subject.call(part) }.to(
        preserve { part.instance_variable_get(ivar_name) }
      )
    end

    it "sets @enmail_rfc18467_encoding_restrictions ivar for all deeply " +
      "nested non-multipart subparts of given part" do
      part = ::Mail::Part.new
      part.content_type = "multipart/mixed"

      subpart1 = ::Mail::Part.new
      subpart1.content_type = "text/plain"
      part.add_part(subpart1)

      subpart2 = ::Mail::Part.new
      subpart2.content_type = "multipart/mixed"
      part.add_part(subpart2)

      subpart3, subpart4, subpart5 = Array.new(3) do
        p = ::Mail::Part.new
        p.content_type = "text/plain"
        subpart2.add_part(p)
        p
      end

      expect { subject.call(part) }.to(
        preserve { part.instance_variable_get(ivar_name) } &
        change { subpart1.instance_variable_get(ivar_name) }.to(true) &
        preserve { subpart2.instance_variable_get(ivar_name) } &
        change { subpart3.instance_variable_get(ivar_name) }.to(true) &
        change { subpart4.instance_variable_get(ivar_name) }.to(true) &
        change { subpart5.instance_variable_get(ivar_name) }.to(true)
      )
    end
  end

  describe "#build_encrypted_part" do
    subject { adapter.method(:build_encrypted_part) }
    let(:encrypted) { enc_dummy }
    let(:enc_dummy) { "DUMMY-PGP-MESSAGE" }

    it "builds a MIME part with correct content type" do
      retval = subject.(encrypted)
      expect(retval).to be_instance_of(::Mail::Part)
      expect(retval.mime_type).to eq("application/octet-stream")
      expect(retval.body.decoded).to eq(enc_dummy)
    end
  end

  describe "#build_encryption_control_part" do
    subject { adapter.method(:build_encryption_control_part) }

    before do
      allow(adapter).
        to receive(:encryption_control_information).and_return("DUMMY")
    end

    it "builds a MIME part with correct content type" do
      retval = subject.call
      expect(retval).to be_instance_of(::Mail::Part)
      expect(retval.mime_type).to eq(custom_enc_protocol)
      expect(retval.body.decoded).to eq("DUMMY")
    end
  end

  describe "#build_signature_part" do
    subject { adapter.method(:build_signature_part) }
    let(:signature) { sig_dummy }
    let(:sig_dummy) { "DUMMY-PGP-SIGNATURE" }

    it "builds a MIME part with correct content type" do
      retval = subject.(signature)
      expect(retval).to be_instance_of(::Mail::Part)
      expect(retval.mime_type).to eq(custom_sign_protocol)
      expect(retval.body.decoded).to eq(sig_dummy)
    end
  end

  describe "#multipart_signed_content_type" do
    subject { adapter.method(:multipart_signed_content_type) }
    let(:args) { { micalg: "micalg", protocol: "protocol" } }

    it "returns a string" do
      expect(subject.call(args)).to be_a(String)
    end

    it "has a MIME type multipart/signed" do
      retval_segments = subject.call(args).split(/\s*;\s*/)
      expect(retval_segments[0]).to eq("multipart/signed")
    end

    it "tells about SHA1 message integrity algorithm given as argument" do
      # To guarantee it is different from other value defined in helper
      micalg = "#{custom_micalg}-1"
      args[:micalg] = micalg
      retval_segments = subject.call(args).split(/\s*;\s*/)
      micalg_def = %[micalg="#{micalg}"]
      expect(retval_segments[1..-1]).to include(micalg_def)
    end

    it "defaults micalg argument to value returned by " +
      "#message_integrity_algorithm" do
      args.delete :micalg
      retval_segments = subject.call(args).split(/\s*;\s*/)
      micalg_def = %[micalg="#{adapter.message_integrity_algorithm}"]
      expect(retval_segments[1..-1]).to include(micalg_def)
    end

    it "tells about PGP protocol given as argument" do
      # To guarantee it is different from other value defined in helper
      sign_protocol = "#{custom_sign_protocol}-1"
      args[:protocol] = sign_protocol
      retval_segments = subject.call(args).split(/\s*;\s*/)
      protocol_def = %[protocol="#{sign_protocol}"]
      expect(retval_segments[1..-1]).to include(protocol_def)
    end

    it "defaults protocol argument to value returned by #sign_protocol" do
      args.delete :protocol
      retval_segments = subject.call(args).split(/\s*;\s*/)
      protocol_def = %[protocol="#{adapter.sign_protocol}"]
      expect(retval_segments[1..-1]).to include(protocol_def)
    end
  end

  describe "#multipart_encrypted_content_type" do
    subject { adapter.method(:multipart_encrypted_content_type) }
    let(:args) { { protocol: "protocol" } }

    it "returns a string" do
      expect(subject.call(args)).to be_a(String)
    end

    it "has a MIME type multipart/encrypted" do
      retval_segments = subject.call(args).split(/\s*;\s*/)
      expect(retval_segments[0]).to eq("multipart/encrypted")
    end

    it "tells about PGP protocol given as argument" do
      # To guarantee it is different from other value defined in helper
      encryption_protocol = "#{custom_enc_protocol}-1"
      args[:protocol] = encryption_protocol
      retval_segments = subject.call(args).split(/\s*;\s*/)
      protocol_def = %[protocol="#{encryption_protocol}"]
      expect(retval_segments[1..-1]).to include(protocol_def)
    end

    it "defaults protocol argument to value returned by #encryption_protocol" do
      args.delete :protocol
      retval_segments = subject.call(args).split(/\s*;\s*/)
      protocol_def = %[protocol="#{adapter.encryption_protocol}"]
      expect(retval_segments[1..-1]).to include(protocol_def)
    end
  end
end
