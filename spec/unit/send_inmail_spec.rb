# frozen_string_literal: true

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

  let(:css_selectors) do
    {
      degree_css: 'degree_css',
      degree_text: 'degree_text',
      subject_placeholder: 'subject_placeholder',
      message_placeholder: 'message_placeholder',
      message_container: 'message_container',
      message_button_css: 'message_button_css',
      message_button_text: 'message_button_text',
      send_button_text: 'message_button_text'
    }
  end

  # Before every test we mock the CssSelectors::SendInmail module, which is used by SendInmail class.
  before do
    css_selectors.each do |key, value|
      allow_any_instance_of(CssSelectors::SendInmail).to receive(key.to_s).and_return(value)
    end

    # Mocking (you can see all the methods in spec/unit/helpers/send_inmail_helpers.rb)
    visit_succeed(profile_url)
    has_selector(message_button_css, text: message_button_text, wait: 0)
    lead_is_not_friended
    click_button_success(message_button_text)
    write_subject_succeed
    write_message_succeed
    send_message_succeed
    message_has_been_sent_successfully
  end

  describe '.initialize' do
    it { is_expected.to eq Salesnavot::SendInmail }
  end

  describe '.execute' do
    context 'everything is ok in order to send the inmail' do
      it 'sends successfully an inmail' do
        result = send_inmail_instance.execute
        expect(result).to be(true)
      end
    end

    context "Can't find message button" do
      before { message_button_not_found }

      it { expect { send_inmail_instance.execute }.to raise_error(Salesnavot::CssNotFound) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{message_button_css}/) }
    end

    context 'the selector for friend degree was not found' do
      before { friend_degree_selector_not_found }
      it { expect { send_inmail_instance.execute }.to raise_error(Salesnavot::CssNotFound) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{degree_css}/) }
    end
    context 'the selector for friend degree was found but the lead is a friend' do
      before { lead_is_friended }
      it { expect { send_inmail_instance.execute }.to raise_error(Salesnavot::LeadIsFriend) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{profile_url}/) }
    end
    context 'when we are unable to click on message button' do
      before { click_on_message_button_fails }
      it { expect { send_inmail_instance.execute }.to raise_error(Capybara::ElementNotFound) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{message_button_text}/) }
    end
    context 'when we are unable to find the subject field' do
      before { subject_field_not_found }
      it { expect { send_inmail_instance.execute }.to raise_error(Capybara::ElementNotFound) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{subject_placeholder}/) }
    end
    context 'when we are unable to find the message field' do
      before { message_field_not_found }
      it { expect { send_inmail_instance.execute }.to raise_error(Capybara::ElementNotFound) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{message_placeholder}/) }
    end
    context 'when we are unable to click on send button' do
      before { send_button_not_found }
      it { expect { send_inmail_instance.execute }.to raise_error(Capybara::ElementNotFound) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{send_button_text}/) }
    end
    context 'the selector which should contain the sent message was not found' do
      before { sent_message_not_found }
      it { expect { send_inmail_instance.execute }.to raise_error(Salesnavot::CssNotFound) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{message_container}/) }
    end
  end
end
