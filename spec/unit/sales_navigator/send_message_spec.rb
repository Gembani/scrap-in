require 'spec_helper'

RSpec.describe ScrapIn::SalesNavigator::SendMessage do
  include CssSelectors::SalesNavigator::SendMessage
  include ScrapIn::Tools

  let(:subject) { described_class }
  let(:salesnav_messages_instance) { subject.new(session, thread, message) }

  let(:session) { instance_double('Capybara::Session', 'session') }
  let(:thread) { 'Lead\'s conversation thread' }
  let(:message) { 'Message to send to lead' }

  let(:messages_array) { [] }

  let(:conversation_array) { [] }

  let(:message_field_node) { instance_double('Capybara::Node::Element', 'message_field_node') }
  let(:button_node) { instance_double('Capybara::Node::Element', 'button_node') }

  let(:new_node) { instance_double('Capybara::Node::Element', 'new_node') }

  before do
    allow(session).to receive(:visit)
    10.times { messages_array << Faker::Lorem.unique.sentence }
    has_selector(session, messages_css)
    allow(session).to receive(:all).with(messages_css).and_return(conversation_array)
    create_node_array(conversation_array, messages_array.length, 'conversation_node')

    has_selector(session, message_field_css)
    find(session, message_field_node, message_field_css)
    allow(message_field_node).to receive(:send_keys).with(message).and_return(conversation_array << new_node)

    conversation_array.each_with_index do |conversation, index|
      allow(conversation).to receive(:text).and_return(messages_array[index])
    end
    allow(new_node).to receive(:text).and_return(message)

    has_selector(session, send_button_css)
    find(session, button_node, send_button_css)
    allow(button_node).to receive(:click).and_return(true)
  end
  
  context 'when cannot load conversation' do
    context 'when fails to load' do
      before { allow(session).to receive(:all).with(messages_css).and_return([]) }
      it { expect(salesnav_messages_instance.execute).to eq(false) }
    end

    context 'when cannot find messages_css' do
      before do
        has_not_selector(session, messages_css)
        allow(session).to receive(:all).with(messages_css).and_return([])
      end
      it { expect(salesnav_messages_instance.execute).to eq(false) }
    end
  end

  context 'when cannot find message_field_css' do
    before { has_not_selector(session, message_field_css) }
    it { expect { salesnav_messages_instance.execute }.to raise_error(ScrapIn::CssNotFound) }
  end

  context 'when cannot find button_css' do
    before { has_not_selector(session, send_button_css) }
    it { expect { salesnav_messages_instance.execute }.to raise_error(ScrapIn::CssNotFound) }
  end

  context 'when fails to load messages after sending for some reason' do
    before do
      has_not_selector(session, messages_css)
      allow(session).to receive(:all).with(messages_css).and_return(conversation_array, [])
    end
    it { expect(salesnav_messages_instance.execute).to eq(false) }
  end

  context 'when fails to send message for some reason, the last message is not the one expected' do
    before { allow(conversation_array).to receive(:[]).with(-1).and_return(conversation_array[0]) }
    it { expect(salesnav_messages_instance.execute).to eq(false) }
  end

  context 'when class sends message to lead' do
    it { expect(salesnav_messages_instance.execute).to eq(true) }
  end
end