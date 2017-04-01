require "spec_helper"

RSpec.describe EnMail::CertificateFinder do
  describe ".find_by_email" do
    context "with existing certificates" do
      it "returns certificate with private key" do
        email = "enmail@ribosetest.com"

        certificate_finder = EnMail::CertificateFinder.find_by_email(email)

        expect(certificate_finder.certificate).not_to be_nil
        expect(certificate_finder.private_key).not_to be_nil
      end
    end
  end
end
