RSpec::Matchers.define :be_a_valid_pgp_signature_of do |text|
  match do |signature|
    validity = false
    begin
      ::GPGME::Crypto.new.verify(signature, signed_text: text) do |sig|
        validity = sig.valid?
      end
    rescue GPGME::Error::NoData # Signature parse error
    end
    validity
  end
end
