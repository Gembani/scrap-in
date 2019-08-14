# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::SendInmail do
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

  include CssSelectors::SendInmail
  before do
    # For more clear results without all the logs
    disable_puts_for_class(ScrapIn::SendInmail)

    # Mocking (you can see all the methods in spec/unit/helpers/send_inmail_helpers.rb)
    visit_succeed(profile_url)
    has_selector(message_button_css, text: message_button_text, wait: 0)
    lead_is_not_friended
    click_button_success(message_button_text)
    write_subject_succeed
    write_message_succeed
    click_button_success(send_button_text)
    has_selector(message_container, text: inmail_message, wait: 5)
  end

  describe '.initialize' do
    it { is_expected.to eq ScrapIn::SendInmail }
  end

  describe '.execute' do
    context 'everything is ok in order to send the inmail' do
      it 'sends successfully an inmail' do
        result = send_inmail_instance.execute
        expect(result).to be(true)
      end
    end

    context "Can't find message button" do
      before { has_not_selector(message_button_css, text: message_button_text, wait: 0) }
      
      it { expect { send_inmail_instance.execute }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{message_button_css}/) }
    end

    context 'the selector for friend degree was not found' do
      before { has_not_selector(degree_css, wait: 5) }
      it { expect { send_inmail_instance.execute }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{degree_css}/) }
    end

    context 'the selector for friend degree was found but the lead is a friend' do
      before { has_selector(degree_css, text: degree_text, wait: 5) }
      it { expect { send_inmail_instance.execute }.to raise_error(ScrapIn::LeadIsFriend) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{profile_url}/) }
    end
    context 'when we are unable to click on message button' do
      before { click_button_fails(message_button_text)}
      it { expect { send_inmail_instance.execute }.to raise_error(Capybara::ElementNotFound) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{message_button_text}/) }
    end
    context 'when we are unable to find the subject field' do
      before { cannot_find_field_with_placeholder(subject_placeholder)}
      it { expect { send_inmail_instance.execute }.to raise_error(Capybara::ElementNotFound) }
      xit { expect { send_inmail_instance.execute }.to raise_error(/#{subject_placeholder}/) }
      # Weird behavior with parenthesis in placeholder ...
    end
    context 'when we are unable to find the message field' do
      before { cannot_find_field_with_placeholder(message_placeholder)}
      it { expect { send_inmail_instance.execute }.to raise_error(Capybara::ElementNotFound) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{message_placeholder}/) }
    end
    context 'when we are unable to click on send button' do
      before { click_button_fails(send_button_text) }
      it { expect { send_inmail_instance.execute }.to raise_error(Capybara::ElementNotFound) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{send_button_text}/) }
    end
    context 'the selector which should contain the sent message was not found' do
      before { has_not_selector(message_container, text: inmail_message, wait: 5) }
      it { expect { send_inmail_instance.execute }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { send_inmail_instance.execute }.to raise_error(/#{message_container}/) }
    end
  end
end
