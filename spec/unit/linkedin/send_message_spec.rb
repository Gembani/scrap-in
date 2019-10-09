require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::SendMessage do
  include CssSelectors::LinkedIn::SendMessage

  let(:subject) do
    described_class.new(session, profile, message_content)
  end
  let(:session) { instance_double('Capybara::Session') }
  let(:profile) { 'Linkedin profile url' }
  let(:message_content) { 'Message content' }

  let(:message_field_node) { instance_double('Capybara::Node::Element', 'message_field_node') }
  let(:send_button_node) { instance_double('Capybara::Node::Element', 'send_button_node') }

  let(:messages_array) { [] }
  let(:messages_content_array) { [] }

  let(:new_node) { instance_double('Capybara::Node::Element', 'new_node') }
  before do
    disable_puts
    allow(session).to receive(:visit).with(profile).and_return(true)
    allow(session).to receive(:click_button).and_return(true)
    10.times { messages_content_array << Faker::Lorem.unique.sentence }
    create_node_array(messages_array, messages_content_array.length, 'messages_node')

    has_selector(session, message_field_css)
    find(session, message_field_node, message_field_css)
    allow(message_field_node).to receive(:send_keys).with(message_content).and_return(messages_array << new_node)
    
    has_selector(session, messages_css)
    allow(session).to receive(:all).with(messages_css).and_return(messages_array)
    messages_array.each_with_index do |message, index|
      allow(message).to receive(:text).and_return(messages_content_array[index])
    end

    allow(new_node).to receive(:text).and_return(message_content)

    has_selector(session, send_button_css)
    find(session, send_button_node, send_button_css)
    allow(send_button_node).to receive(:click)
  end

  context 'when no message_field_css' do
    before { has_not_selector(session, message_field_css) }
    it { expect { subject.execute }.to raise_error(ScrapIn::CssNotFound) }
  end

  context 'when no send_button_css' do
    before { has_not_selector(session, send_button_css) }
    it { expect { subject.execute }.to raise_error(ScrapIn::CssNotFound) }
  end

  context 'when no sent_message_css' do
    before do
      has_not_selector(session, messages_css)
      allow(session).to receive(:all).with(messages_css).and_return([])
    end
    it { expect(subject.execute).to eq(false) }
  end

  context 'when an error occured when sending message' do
    before { allow(messages_array).to receive(:[]).with(-1).and_return(messages_array[0]) }
    it { expect(subject.message_sent?).to eq(false) }
  end

  context 'when class sends message to lead' do
    it { expect(subject.execute).to eq(true) }
  end

  context 'when wants the class to do the job but do not send the message' do
    before { subject.execute(false) }
    it { expect(session).to have_received(:visit) }
    it { expect(message_field_node).to have_received(:send_keys) }
    it { expect(subject.execute(false)).to eq(false) }
  end
end
