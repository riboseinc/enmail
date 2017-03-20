require "spec_helper"

class TestMailer < ActionMailer::Base
  include Mail::Secure::PGPMailable

  def test headers={}
    mail({
      to: 'test-recipient@example.com',
      from: 'test-sender@example.com'
    }.merge(headers)) do |format|
      format.text { render plain: "test message" }
      format.html { render html: "<h1>test message</h1>".html_safe }
    end
  end
end

RSpec.describe MailInterceptors::PGP do

  describe '.delivering_email' do
    let(:orig_mail) {
      Mail.new do
        to 'test-recipient@example.com'
        from 'test-sender@example.com'

        text_part do
          'test message'
        end

        html_part do
          '<h1>test message</h1>'
        end

      end
    }

    let(:mail) {
      m = orig_mail
      pp m.headers = add_pgp_headers(m.headers)
      described_class.delivering_email(m)
      m
    }

    it "has a signed part" do
      expect(mail.parts).to satisfy do |parts|
        parts.detect{|part| part.is_a?(Mail::Gpg::SignedPart) }
      end
    end

    it "has a sign part" do
      expect(mail.parts).to satisfy do |parts|
        parts.detect{|part| part.is_a?(Mail::Gpg::SignPart) }
      end
    end

  end


  describe 'interception of ActionMailer::Base' do
    before(:each) do
      ActionMailer::Base.deliveries.clear
      ActionMailer::Base.register_interceptor(MailInterceptors::PGP)
      m = TestMailer.test
      m.deliver
    end

    let(:mail) {
      Mail::TestMailer.deliveries.last
    }

    it "has a signed part" do
      expect(mail.parts).to satisfy do |parts|
        parts.detect{|part| part.is_a?(Mail::Gpg::SignedPart) }
      end
    end

    it "has a sign part" do
      expect(mail.parts).to satisfy do |parts|
        parts.detect{|part| part.is_a?(Mail::Gpg::SignPart) }
      end
    end

    it "has 2 parts" do
      expect(mail.parts.length).to eq(2)
    end

  end

end

# adapter model for separating netpgp, gpgme and smime
# simple structure for demo to contractor
# empty adapter OK
