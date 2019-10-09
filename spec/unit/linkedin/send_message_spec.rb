require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::SendMessage do
  include CssSelectors::LinkedIn::SendMessage

  let(:session) { instance_double('Capybara::Session') }

  let(:message_button_array) { [message_button_node] }
  let(:message_button_node) { instance_double('Capybara::Node::Element', 'message_button_node') }
  let(:message_field_node) { instance_double('Capybara::Node::Element', 'message_field_node') }
  let(:send_button_node) { instance_double('Capybara::Node::Element', 'send_button_node') }

  let(:sent_message_array) { [] }
  let(:sent_message_node) { instance_double('Capybara::Node::Element', 'sent_message_node') }

  let(:messages_array) { [] }
  let(:message_content) { 'Message content' }
  let(:profile) { 'Linkedin profile url' }
  let(:subject) do
    described_class.new(session, profile, message_content)
  end

  let(:new_node) { instance_double('Capybara::Node::Element', 'new_node') }
  before do
    disable_puts
    allow(session).to receive(:visit).with(profile).and_return(true)
    allow(session).to receive(:click_button).and_return(true)
    10.times { messages_array << Faker::Lorem.unique.sentence }
    create_node_array(sent_message_array, messages_array.length, 'sent_message_node')
    
    has_selector(session, message_button_css)
    allow(session).to receive(:all).with(message_button_css).and_return(message_button_array)

    has_selector(session, message_field_css)
    find(session, message_field_node, message_field_css)
    allow(message_field_node).to receive(:send_keys).with(message_content).and_return(sent_message_array << new_node)
    
    has_selector(session, sent_message_css)
    allow(session).to receive(:all).with(sent_message_css).and_return(sent_message_array)
    sent_message_array.each_with_index do |message, index|
      allow(message).to receive(:text).and_return(messages_array[index])
    end

    allow(new_node).to receive(:text).and_return(message_content)

    has_selector(session, send_button_css)
    find(session, send_button_node, send_button_css)
    allow(send_button_node).to receive(:click)
  end

  context 'when too long to load buttons or has not selector message_button_css' do
    let(:message_button_array) { [] }
    it { expect { subject.execute }.to raise_error('Cannot load profile. Timeout !') }
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
      has_not_selector(session, sent_message_css)
      allow(session).to receive(:all).with(sent_message_css).and_return([])
    end
    it { expect(subject.execute).to eq(false) }
  end

  context 'when an error occured when sending message' do
    before { allow(sent_message_array).to receive(:[]).with(-1).and_return(sent_message_array[0]) }
    it { expect(subject.message_sent?).to eq(false) }
  end

  context 'when class sends message to lead' do
    it { expect(subject.execute).to eq(true) }
  end
end
