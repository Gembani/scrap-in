require 'spec_helper'

RSpec.describe ScrapIn::SalesNavigator::SendMessage do
  include CssSelectors::SalesNavigator::SendMessage
  include ScrapIn::Tools

  let(:subject) {described_class }
  let(:salesnav_messages_instance) { subject.new(session, thread, message) }

  let(:session) { instance_double('Capybara::Session', 'session') }
  let(:thread) { 'Lead\'s conversation thread' }
  let(:message) { 'Message to send to lead' }

  let(:messages_array) { [] }
  before do
    allow(session).to receive(:visit)
    10.times { messages_array << Faker::Lorem.unique.sentence }
  end
  
  context '' do
    it do
      puts messages_array
    end
  end
end