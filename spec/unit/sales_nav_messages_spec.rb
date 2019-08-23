# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::SalesNavMessages do
  include CssSelectors::SalesNavMessages
  include Tools

  let(:session) { instance_double('Capybara::Session') }
  let(:sales_messages) { instance_double('Capybara::Node::Element') }
  let(:message_thread) { instance_double('Capybara::Node::Element') }

  let(:subject) do
    described_class
  end

  let(:salesnav_messages_instance) do
    subject.new(session, thread_link)
  end

  let(:node_array) { [] }
  let(:message_thread_elements) { [] }
  let(:sales_loaded_messages) { [] }

  let(:thread_link) { ('Conversation link to scrap') }

  before do
    # For more clear results without all the logs
    # disable_puts_for_class(ScrapIn::SalesNavMessages)
    allow_any_instance_of(ScrapIn::SalesNavMessages).to receive(:sleep).and_return(0)
    allow_any_instance_of(ScrapIn::SalesNavMessages).to receive(:scroll_down_to)
    visit_succeed(thread_link)
    allow(session).to receive(:has_selector?).and_return(true)
    
    create_node_array(message_thread_elements, 3)
    create_node_array(sales_loaded_messages)
    create_conversation_array(message_thread_elements)
    
    has_selector(message_thread, message_thread_elements_css, wait: 5)
    has_selector(sales_messages, message_thread_css, wait: 5)
    allow(message_thread).to receive(:all).with(message_thread_elements_css, wait: 5).and_return(message_thread_elements)
    allow(sales_messages).to receive(:find).with(message_thread_css, wait: 5).and_return(message_thread)
    
    allow(session).to receive(:all).with(sales_loaded_messages_css, wait: 5).and_return(sales_loaded_messages)
    allow(session).to receive(:first).with(sales_messages_css, wait: 5).and_return(sales_messages)
  end

  describe '.initialize' do
    it { is_expected.to eq ScrapIn::SalesNavMessages }
  end

  describe '.execute' do
    context 'when everything is ok in order to scrap conversation messages' do
      it 'puts successfully messages and direction' do
        salesnav_messages_instance.execute(10) do |message, direction| 
          print direction
          puts " #{message}"
        end
        expect { salesnav_messages_instance.execute(10).to true }
      end
    end

    context 'when execute with 0 messages expected' do
      it 'returns true' do
        salesnav_messages_instance.execute(0) { |message, direction| }
        expect { salesnav_messages_instance.execute(0).to true }
      end
    end

    context 'when cannot load conversation\'s messages' do
      before do

      end
    end
  end
end
# expect { send_inmail_instance.execute }.to raise_error(ScrapIn::CssNotFound)
# expect { send_inmail_instance.execute }.to raise_error(/#{message_container}/)