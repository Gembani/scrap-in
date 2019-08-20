# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::SalesNavMessages do
  include CssSelectors::SalesNavMessages

  let(:session) { instance_double('Capybara::Session') }
  let(:sales_messages) { instance_double('Capybara::Node::Element') }

  let(:subject) do
    described_class
  end

  let(:salesnav_messages_instance) do
    subject.new(session, thread_link)
  end

  let(:thread_link) { ('Conversation link to scrap') }

  before do
    # For more clear results without all the logs
    disable_puts_for_class(ScrapIn::SalesNavMessages)
    visit_succeed(thread_link)
    has_selector(sales_messages_css, wait: 5) # first
    has_selector(message_thread_css, wait: 5) # find
    has_selector(message_thread_elements_css, wait: 5) # all
    has_selector(sales_loaded_messages_css, wait: 5) # all
    has_selector(content_css, wait: 5) # find
    has_selector(sender_css, wait: 2, visible: false) # first
    allow_any_instance_of(ScrapIn::SalesNavMessages).to receive(:sleep).with(0)
    allow(sales_messages).to receive(:count).and_return(1)
    allow(session).to receive(:all).and_return(sales_messages)
  end

  describe '.initialize' do
    it { is_expected.to eq ScrapIn::SalesNavMessages }
  end

  describe '.execute' do
    context 'everything is ok in order to scrap conversation messages' do
      it 'puts successfully messages and direction' do
        salesnav_messages_instance.execute(1) do |message, direction|
          puts message
        end
        # expect { send_inmail_instance.execute }.to raise_error(ScrapIn::CssNotFound)
        # expect { send_inmail_instance.execute }.to raise_error(/#{message_container}/)
      end
    end
  end
end