# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapMessages do
  include CssSelectors::LinkedIn::ScrapMessages
  include ScrapIn::Tools

  let(:session) { instance_double('Capybara::Session') }
  let(:linkedin_messages_instance) { described_class.new(session, thread_link) }
  let(:thread_link) { 'Conversation url' }

  let(:all_messages_array) { [] }
  let(:bigger_conversation_array) { [] }
  let(:messages_thread_array) { [] }
  let(:messages_array) { [] }

  let(:message_content) { 'This is the message number ' }
  before do
    disable_script
    disable_method(:puts)

    create_node_array(messages_thread_array, 1, 'messages_thread_node')
    create_node_array(all_messages_array, 5, 'all_messages_node')
    create_node_array(bigger_conversation_array, 20, 'bigger_conversation_node')

    visit_succeed(thread_link)
    has_selector(session, messages_thread_css)
    allow(session).to receive(:all).and_return(messages_thread_array, all_messages_array)

    has_selector(session, all_messages_css)
    allow(session).to receive(:first).with(all_messages_css).and_return(all_messages_array[0])

    create_node_array(messages_array, bigger_conversation_array.length, 'messages_node')
    messages_array.each_with_index do |message, index|
      allow(message).to receive(:text).and_return("#{message_content} #{index}")
    end

    all_messages_array.each_with_index do |message, index|
      has_selector(message, message_content_css)
      allow(message).to receive(:find).with(message_content_css).and_return(messages_array[index])
      direction = index.even? ? sender_css : 'The sender is the lead'
      allow(message).to receive(:[]).with(:class).and_return(direction)
      allow(message).to receive(:native)
    end
  end

  context 'when it fails somewhere' do
    context 'when number of messages is not positive' do
      it { expect { linkedin_messages_instance.execute(-1) { |message, direction| } }.to raise_error(ArgumentError) }
    end
  
    context 'when fails to visit linkedin page' do
      before do
        has_not_selector(session, messages_thread_css)
        allow(session).to receive(:all).with(messages_thread_css).and_return([])
      end
      it { expect { linkedin_messages_instance.execute(10) { |message, direction| } }.to raise_error(ArgumentError) }
    end
  
    context 'when cannot load messages' do
      before do
        has_not_selector(session, all_messages_css)
        allow(session).to receive(:all).with(all_messages_css).and_return([])
      end
      it { expect { linkedin_messages_instance.execute(10) { |message, direction| } }.to raise_error(ArgumentError) }
    end

    context 'when cannot find message_content_css' do
      before do
        all_messages_array.each do |message|
          has_not_selector(message, message_content_css)
        end
      end
      it do
        expect { linkedin_messages_instance.execute(5) { |_message, _direction| } }
          .to raise_error(ScrapIn::CssNotFound)
      end
    end
  end

  context 'when everything is ok' do
    context '' do
      it do
        count = 0
        linkedin_messages_instance.execute(10) do |message, direction|
          print direction
          puts ' ' + message
          count += 1
        end
        expect(count).to eq(all_messages_array.length)
      end
    end

    context 'when needs to scroll to twice to load more messages' do
      before do
        allow(session).to receive(:all).and_return(messages_thread_array, all_messages_array, bigger_conversation_array)
        allow(session).to receive(:first).with(all_messages_css)
                                         .and_return(all_messages_array[0], bigger_conversation_array[0])

        bigger_conversation_array.each_with_index do |message, index|
          has_selector(message, message_content_css)
          allow(message).to receive(:find).with(message_content_css).and_return(messages_array[index])
          direction = index.even? ? sender_css : 'The sender is the lead'
          allow(message).to receive(:[]).with(:class).and_return(direction)
          allow(message).to receive(:native)
        end
      end
      it do
        number_of_time = 10
        count = 0
        linkedin_messages_instance.execute(number_of_time) do |message, direction|
          print direction
          puts ' ' + message
          count += 1
        end
        expect(count).to eq(number_of_time)
      end
    end

    context 'when no number of message specified and the conversation has at leat 20 messages' do
      before do
        allow(session).to receive(:all).and_return(messages_thread_array, bigger_conversation_array)

        bigger_conversation_array.each_with_index do |message, index|
          has_selector(message, message_content_css)
          allow(message).to receive(:find).with(message_content_css).and_return(messages_array[index])
          direction = index.even? ? sender_css : 'The sender is the lead'
          allow(message).to receive(:[]).with(:class).and_return(direction)
          allow(message).to receive(:native)
        end
      end
      it do
        count = 0
        linkedin_messages_instance.execute do |message, direction|
          print direction
          puts ' ' + message
          count += 1
        end
        expect(count).to eq(bigger_conversation_array.length)
      end
    end

    context 'when no number of message specified but the conversation does not have at leat 20 messages' do
      it do
        count = 0
        linkedin_messages_instance.execute do |message, direction|
          print direction
          puts ' ' + message
          count += 1
        end
        expect(count).to eq(all_messages_array.length)
      end
    end
  end
end
