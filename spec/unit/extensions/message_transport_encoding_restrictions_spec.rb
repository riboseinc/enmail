# (c) Copyright 2018 Ribose Inc.
#

require "spec_helper"

RSpec.describe EnMail::Extensions::MessageTransportEncodingRestrictions do
  describe "::identify_and_set_transfer_encoding" do
    let(:textual_part) do
      m = Mail::Part.new
      m.content_type = "text/plain"
      m.body = "Whatever!"
      m
    end

    let(:binary_part) do
      m = Mail::Part.new
      m.content_type = "image/jpeg"
      m.body = SMALLEST_JPEG
      m
    end

    let(:multipart) do
      m = Mail::Part.new
      m.content_type = "multipart/mixed"
      m.add_part(textual_part)
      m.add_part(binary_part)
      m
    end

    before do
      if with_encoding_restrictions
        ivar = "@enmail_rfc18467_encoding_restrictions"
        part.instance_variable_set(ivar, true)
      end

      # The 8bit encoding is universal and most space efficient.  Setting it as
      # preferred one will prevent Mail gem from escaping any non-ascii
      # character (by using base64 or quoted-printable encodings).
      #
      # Thanks to that, we are able to test whether EnMail's custom restrictions
      # do work as intended, and override default behaviour.
      part.transport_encoding = "8bit"

      # Prepare mail part to being sent.  For this examples, it roughly means
      # "encode message and add proper headers".
      part.ready_to_send!
    end

    context "when encoding restrictions are required" do
      let(:with_encoding_restrictions) { true }

      context "and body looks textual" do
        let(:part) { textual_part }

        specify "best compatible transport encoding is used (here: 7bit)" do
          expect(part.content_transfer_encoding).to eq("quoted-printable")
        end
      end

      context "and body looks binary" do
        let(:part) { binary_part }

        specify "best compatible transport encoding is used (here: 8bit)" do
          expect(part.content_transfer_encoding).to eq("base64")
        end
      end

      context "and message or part is compound" do
        let(:part) { multipart }

        specify "best compatible transport encoding is used" do
          expect(part.content_transfer_encoding).to eq("8bit")
        end
      end
    end

    context "when encoding restrictions are not required" do
      let(:with_encoding_restrictions) { false }

      context "and body looks textual" do
        let(:part) { textual_part }

        specify "best compatible transport encoding is used (here: 7bit)" do
          expect(part.content_transfer_encoding).to eq("7bit")
        end
      end

      context "and body looks binary" do
        let(:part) { binary_part }

        specify "best compatible transport encoding is used (here: 8bit)" do
          expect(part.content_transfer_encoding).to eq("8bit")
        end
      end

      context "and message or part is compound" do
        let(:part) { multipart }

        specify "best compatible transport encoding is used" do
          expect(part.content_transfer_encoding).to eq("8bit")
        end
      end
    end
  end
end
