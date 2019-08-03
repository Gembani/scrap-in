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

  # Before every test we mock the CssSelectors::SendInmail, which is used by SendInmail class.
  before do
    css_selectors.each do |key, value|
      allow_any_instance_of(CssSelectors::SendInmail).to receive(key.to_s).and_return(value)
    end

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

    # message_sent? return true
    allow(session).to receive(:has_selector?).with(message_container, text: inmail_message, wait: 5).and_return(true)
  end

  describe '.initialize' do
    it { is_expected.to eq Salesnavot::SendInmail }
  end

  describe '.execute' do
    context 'Tout est ok' do
      it 'sends successfully an inmail' do
        result = send_inmail_instance.execute
        expect(result).to be(true)
      end
    end
    context 'Can\'t find message button' do
      before do
        allow(session).to receive(:has_selector?)
          .with(message_button_css, text: message_button_text, wait: 0).and_return(false)
      end
      it 'raises a css error' do
        expect { send_inmail_instance.execute }.to raise_error(Salesnavot::CssNotFound)
      end
    end
    context 'can\'t find message button' do
      before do
        allow(session).to receive(:has_selector?)
          .with(message_button_css, text: message_button_text, wait: 0).and_return(false)
      end
      it 'raises the correct css error' do
        expect { send_inmail_instance.execute }.to raise_error(Salesnavot::CssNotFound)
      end
      it 'raises an error with css selector as an instance variable' do
        expect { send_inmail_instance.execute }.to raise_error(/#{message_button_css}/)
      end
    end
    context 'the selector for friend degree was not found' do
      before do
        allow(session).to receive(:has_selector?).with(degree_css, wait: 5).and_return(false)
      end
      it 'raises the correct css error' do
        expect { send_inmail_instance.execute }.to raise_error(Salesnavot::CssNotFound)
      end
      it 'raises an error with css selector as an instance variable' do
        expect { send_inmail_instance.execute }.to raise_error(/#{degree_css}/)
      end
    end
    context 'the selector for friend degree was found but the lead is a friend' do
      before do
        allow(session).to receive(:has_selector?).with(degree_css, text: degree_text, wait: 5).and_return(true)
      end
      it 'raises the correct css error' do
        expect { send_inmail_instance.execute }.to raise_error(Salesnavot::LeadIsFriend)
      end
      it 'raises an error with css selector as an instance variable' do
        expect { send_inmail_instance.execute }.to raise_error(/#{profile_url}/)
      end
    end
    context 'when we are unable to click on message button' do
      before do
        allow(session).to receive(:click_button).with(message_button_text)
                                                .and_raise(Capybara::ElementNotFound, "Unable to find button '#{message_button_text}' that is not disabled")
      end
      it 'raises the correct css error' do
        expect { send_inmail_instance.execute }.to raise_error(Capybara::ElementNotFound)
      end
      it 'raises an error with css selector as an instance variable' do
        expect { send_inmail_instance.execute }.to raise_error(/#{message_button_text}/)
      end
    end
    context 'when we are unable to find the subject field' do
      before do
        exception = "Unable to find field that is not disabled with placeholder #{subject_placeholder}"
        allow(session).to receive(:find_field).with(placeholder: subject_placeholder)
                                              .and_raise(Capybara::ElementNotFound, exception)
      end
      it 'raises the correct css error' do
        expect { send_inmail_instance.execute }.to raise_error(Capybara::ElementNotFound)
      end
      it 'raises an error with css selector as an instance variable' do
        expect { send_inmail_instance.execute }.to raise_error(/#{subject_placeholder}/)
      end
    end
    context 'when we are unable to find the message field' do
      before do
        exception = "Unable to find field that is not disabled with placeholder #{message_placeholder}"
        allow(session).to receive(:find_field).with(placeholder: message_placeholder)
                                              .and_raise(Capybara::ElementNotFound, exception)
      end
      it 'raises the correct css error' do
        expect { send_inmail_instance.execute }.to raise_error(Capybara::ElementNotFound)
      end
      it 'raises an error with css selector as an instance variable' do
        expect { send_inmail_instance.execute }.to raise_error(/#{message_placeholder}/)
      end
    end
    context 'when we are unable to click on send button' do
      before do
        allow(session).to receive(:click_button).with(send_button_text)
                                                .and_raise(Capybara::ElementNotFound, "Unable to find button '#{send_button_text}' that is not disabled")
      end
      it 'raises the correct css error' do
        expect { send_inmail_instance.execute }.to raise_error(Capybara::ElementNotFound)
      end
      it 'raises an error with css selector as an instance variable' do
        expect { send_inmail_instance.execute }.to raise_error(/#{send_button_text}/)
      end
    end
    context 'the selector which should contain the sent message was not found' do
      before do
        allow(session).to receive(:has_selector?).with(message_container, text: inmail_message, wait: 5).and_return(false)
      end
      it 'raises the correct css error' do
        expect { send_inmail_instance.execute }.to raise_error(Salesnavot::CssNotFound)
      end
      it 'raises an error with css selector as an instance variable' do
        expect { send_inmail_instance.execute }.to raise_error(/#{message_container}/)
      end
    end
  end
end
