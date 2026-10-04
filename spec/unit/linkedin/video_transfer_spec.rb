require 'spec_helper'
require 'capybara/selenium/node'
require 'tempfile'
require 'base64'

# Exercise the installed Capybara/Selenium file upload code, with only the wire
# endpoint and native element faked. No browser or HTTP connection is created.
RSpec.describe Capybara::Selenium::Node, 'remote video transfer' do
  let(:bridge) do
    Class.new do
      include Selenium::WebDriver::Remote::Features
      attr_accessor :file_detector
      attr_reader :upload_request, :sent_keys

      def execute(command, path, payload)
        raise 'unexpected command' unless command == :upload_file
        @upload_request = payload
        '/tmp/selenium-upload/sample.mp4'
      end

      def send_keys_to_element(_id, keys)
        @sent_keys = upload_if_necessary(keys)
      end
    end.new
  end
  let(:native) { Selenium::WebDriver::Element.new(bridge, 'file-input') }
  let(:driver) { double('remote Capybara driver', options: { browser: :remote }) }
  let(:node) { Capybara::Selenium::Node.new(driver, native) }

  before do
    allow(node).to receive(:bridge).and_return(bridge)
    allow(node).to receive(:attrs).with(:tagName, :type).and_return(%w[INPUT file])
  end

  it 'uploads local bytes and replaces the host path with the Selenium server path' do
    Tempfile.create(['synthetic', '.mp4']) do |file|
      file.write('synthetic video bytes'); file.flush
      node.set(file.path)
      expect(bridge.sent_keys).to eq(['/tmp/selenium-upload/sample.mp4'])
      zipped = Base64.decode64(bridge.upload_request.fetch(:file))
      Zip::InputStream.open(StringIO.new(zipped)) do |zip|
        zip.get_next_entry
        expect(zip.read).to eq('synthetic video bytes')
      end
      expect(bridge.file_detector).to be_nil
      expect(File.read(file.path)).to eq('synthetic video bytes')
    end
  end

  it 'restores detection after an upload error' do
    Tempfile.create(['synthetic', '.mov']) do |file|
      allow(bridge).to receive(:execute).and_raise(Selenium::WebDriver::Error::WebDriverError, 'transfer failed')
      expect { node.set(file.path) }.to raise_error(Selenium::WebDriver::Error::WebDriverError)
      expect(bridge.file_detector).to be_nil
    end
  end
end
