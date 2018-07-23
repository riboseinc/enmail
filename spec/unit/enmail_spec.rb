RSpec.describe EnMail do
  describe "::protect" do
    subject { EnMail.method(:protect) }

    let(:adapter_class) { Class.new }
    let(:adapter_dbl) { double(sign: nil) }
    let(:message) { Mail.new }

    before { allow(adapter_class).to receive(:new).and_return(adapter_dbl) }

    it "instantiates an adapter with proper options" do
      subject.call :sign, message, adapter: adapter_class, proper: :options
      expect(adapter_class).to have_received(:new).with(proper: :options)
    end

    it "calls indicated method on adapter, passing a message as an argument" do
      subject.call :sign, message, adapter: adapter_class
      expect(adapter_dbl).to have_received(:sign).with(message)
    end
  end
end
