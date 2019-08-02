require 'spec_helper'

RSpec.describe Salesnavot::SendInmail do
  let(:subject) do
    described_class
  end

  let(:send_inmail_instance) do 
    subject.new(session, profile_url, subject_text, inmail_message)
  end

  # Variables for initializing
  let(:inmail_message) { 'The inmail we send' }
  let(:profile_url) { 'profile_url' }
  let(:subject_text) { 'subject_text' }
  let(:session) { instance_double('Capybara::Session') }

  # Css selectors
  let(:degree_css) { 'degree_css' }
  let(:degree_text) { 'degree_text' }
  let(:subject_placeholder) { 'subject_placeholder' }
  let(:message_placeholder) { 'message_placeholder' }
  let(:message_container) { 'message_container' }
  let(:message_button_css) { 'message_button_css' }
  let(:message_button_text) { 'message_button_text' }
  let(:send_button_text) { 'message_button_text' }

  describe '.initialize' do
    it { is_expected.to eq Salesnavot::SendInmail }
  end
  describe '.execute' do
    before do
      # stubing class css --> GENERAL
      allow(send_inmail_instance).to receive(:message_button_css)
                                 .and_return(message_button_css)
      allow(send_inmail_instance).to receive(:message_button_text)
                                 .and_return(message_button_text)
      allow(send_inmail_instance).to receive(:send_button_text)
                                 .and_return(send_button_text)
      allow(send_inmail_instance).to receive(:degree_css)
                                 .and_return(degree_css)
      allow(send_inmail_instance).to receive(:degree_text)
                                 .and_return(degree_text)
      allow(send_inmail_instance).to receive(:subject_placeholder)
                                 .and_return(subject_placeholder)
      allow(send_inmail_instance).to receive(:message_placeholder)
                                 .and_return(message_placeholder)
      # visit_profile succeed
      allow(session).to receive(:visit).with(profile_url)
      # searching for message button  
      allow(session).to receive(:has_selector?)
                    .with(message_button_css, text: message_button_text, wait: 0).and_return(true)
      # friend? return false
      allow(session).to receive(:has_selector?).with(degree_css, wait: 5).and_return(true)
      allow(session).to receive(:has_selector?).with(degree_css, text: degree_text, wait: 5).and_return(false)
     # click_message_link succeed 
      allow(session).to receive(:click_button).with(message_button_text).and_return(true)
     # write_subject succeed
      subject_field = instance_double('Capybara::Node::Element')
      allow(subject_field).to receive(:send_keys).with(subject_text)
      allow(session).to receive(:find_field).with(placeholder: subject_placeholder).and_return(subject_field)
     # write_message succeed
      message_field = instance_double('Capybara::Node::Element')
      allow(message_field).to receive(:send_keys).with(inmail_message)
      allow(session).to receive(:find_field).with(placeholder: message_placeholder).and_return(message_field)
     # send_message succeed 
      allow(session).to receive(:click_button).with(send_button_text)
    end
    it 'does not log in into Linkedin and raises an error' do
      result = send_inmail_instance.execute
      expect(result).to be(true)
    end
  end
end
