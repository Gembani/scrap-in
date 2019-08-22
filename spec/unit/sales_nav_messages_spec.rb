# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::SalesNavMessages do
  include CssSelectors::SalesNavMessages

  let(:session) { instance_double('Capybara::Session') }
  let(:sales_messages) { instance_double('Capybara::Node::Element') }
  let(:message_thread) { instance_double('Capybara::Node::Element') }
  let(:content_css) { instance_double('Capybara::Node::Element', 'Content') }
  let(:sender_css) { instance_double('Capybara::Node::Element', 'Sender') }

  let(:subject) do
    described_class
  end

  let(:salesnav_messages_instance) do
    subject.new(session, thread_link)
  end

  let(:node_array) { [] }
  let(:message_thread_elements) { [] }
  let(:sales_loaded_messages) { [] }
  let(:content_array) { [] }
  let(:sender_array) { [] }

  let(:thread_link) { ('Conversation link to scrap') }

  before do
    # For more clear results without all the logs
    disable_puts_for_class(ScrapIn::SalesNavMessages)
    visit_succeed(thread_link)
    allow(session).to receive(:has_selector?).and_return(true)
    # has_selector(sales_messages_css, wait: 5) # first
    # has_selector(session, message_thread_css, wait: 5) # find
    # has_selector(session, message_thread_elements_css, wait: 5) # all
    # has_selector(session, sales_loaded_messages_css, wait: 5) # all
    # has_selector(session, content_css, wait: 5) # find
    # has_selector(session, sender_css, wait: 2, visible: false) # first
    has_selector(session, sales_loaded_messages_css, wait: 5)
    allow_any_instance_of(ScrapIn::SalesNavMessages).to receive(:sleep).and_return(0)
    create_node_array(node_array)
    create_node_array(message_thread_elements, 3)
    create_node_array(sales_loaded_messages)
    allow(session).to receive(:all).and_return(sales_loaded_messages)
    allow(session).to receive(:first).and_return(sales_messages)
    
    has_selector(message_thread, message_thread_elements_css, wait: 5)
    allow(message_thread).to receive(:all).and_return(message_thread_elements)
    has_selector(sales_messages, message_thread_css, wait: 5)
    allow(sales_messages).to receive(:find).and_return(message_thread)

    create_node_array(content_array)
    create_node_array(sender_array)
    count = 0
    message_thread_elements.each do |message|
      has_selector(message, content_css, wait: 5)
      has_selector(message, sender_css, wait: 2, visible: false)
      content_array[count] = { 'innerHTML' => "Message content" }
      sender_array[count] = { 'innerHTML' => "   You   " }
      allow(message).to receive(:find).and_return(content_array[count])
      allow(message).to receive(:first).and_return(sender_array[count])
      count += 1
    end
    # byebug
  end

  describe '.initialize' do
    it { is_expected.to eq ScrapIn::SalesNavMessages }
  end

  describe '.execute' do
    context 'when everything is ok in order to scrap conversation messages' do
      it 'puts successfully messages and direction' do
        salesnav_messages_instance.execute(3) { |message, direction| }
        expect { salesnav_messages_instance.execute(3).to true }
      end
    end

    context 'when execute with 0 messages expected' do
      it 'returns true' do
        salesnav_messages_instance.execute(0) { |message, direction| }
        expect { salesnav_messages_instance.execute(0).to true }
      end
    end
  end
end
# expect { send_inmail_instance.execute }.to raise_error(ScrapIn::CssNotFound)
# expect { send_inmail_instance.execute }.to raise_error(/#{message_container}/)