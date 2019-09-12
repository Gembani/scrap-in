require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::SendMessage do
  include CssSelectors::LinkedIn::SendMessage

  let(:session) { instance_double('Capybara::Session') }

  let(:message_button_array) { [message_button_node] }
  let(:message_button_node) { instance_double('Capybara::Node::Element', 'message_button_node') }
  let(:message_field_node) { instance_double('Capybara::Node::Element', 'message_field_node') }
  let(:send_button_node) { instance_double('Capybara::Node::Element', 'send_button_node') }

  let(:sent_message_array) { [sent_message_node] }
  let(:sent_message_node) { instance_double('Capybara::Node::Element', 'sent_message_node') }

  let(:message_content) { 'Message content' }
  let(:profile) { 'Linkedin profile url' }
  let(:subject) do
    described_class.new(session, profile, message_content)
  end

  before do
    disable_puts_for_class
    allow(session).to receive(:visit).with(profile).and_return(true)
    allow(session).to receive(:click_button).and_return(true)

    has_selector(session, message_button_css)
    allow(session).to receive(:all).with(message_button_css).and_return(message_button_array)

    has_selector(session, message_field_css)
    find(session, message_field_node, message_field_css)
    allow(message_field_node).to receive(:send_keys).with(message_content)

    has_selector(session, send_button_css)
    find(session, send_button_node, send_button_css)
    allow(send_button_node).to receive(:click)

    has_selector(session, sent_message_css)
    allow(session).to receive(:all).with(sent_message_css).and_return(sent_message_array)
    allow(sent_message_node).to receive(:text).and_return(message_content)
  end

  context 'when cannot find message_button_css' do
    before { has_not_selector(session, message_button_css) }
    it { expect { subject.execute }.to raise_error(/#{message_button_css}/) }
    it { expect { subject.execute }.to raise_error(ScrapIn::CssNotFound) }
  end

  context 'when too long to load buttons' do
    let(:message_button_array) { [] }
    it { expect { subject.execute }.to raise_error('Cannot load profile. Timeout !')}
  end

  context 'when no message_field_css' do
    before { has_not_selector(session, message_field_css) }
    it { expect { subject.execute }.to raise_error(/#{message_field_css}/) }
    it { expect { subject.execute }.to raise_error(ScrapIn::CssNotFound) }
  end

  context 'when no send_button_css' do
    before { has_not_selector(session, send_button_css) }
    it { expect { subject.execute }.to raise_error(/#{send_button_css}/) }
    it { expect { subject.execute }.to raise_error(ScrapIn::CssNotFound) }
  end

  context 'when no sent_message_css' do
    before { has_not_selector(session, sent_message_css) }
    it { expect { subject.execute }.to raise_error(/#{sent_message_css}/) }
    it { expect { subject.execute }.to raise_error(ScrapIn::CssNotFound) }
  end

  context 'when an error occured when sending message' do
    before { allow(sent_message_node).to receive(:text).and_return('An error occured') }
    it { expect(subject.message_sent?).to eq(false)}
  end

  context 'when everything is good' do
    before { subject.execute }
    it { expect(session).to have_received(:visit).with(profile) }
    it { expect(message_field_node).to have_received(:send_keys).with(message_content) }
    it { expect(subject.message_sent?).to eq(true)}
  end
end