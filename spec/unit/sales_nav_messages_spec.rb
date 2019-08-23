# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::SalesNavMessages do
  include CssSelectors::SalesNavMessages
  include ScrapIn::Tools

  let(:session) { instance_double('Capybara::Session') }
  let(:sales_messages) { instance_double('Capybara::Node::Element') }
  let(:message_thread) { instance_double('Capybara::Node::Element') }

  let(:subject) do
    described_class
  end

  let(:salesnav_messages_instance) do
    subject.new(session, thread_link)
  end

  let(:message_thread_elements) { [] }
  let(:sales_loaded_messages) { [] }
  let(:bigger_conversation) { [] }

  let(:thread_link) { 'Conversation link to scrap' }

  before do
    # For more clear and fast results without all the logs nor sleeps
    disable_method(:puts)
    disable_method(:sleep)
    # allow_any_instance_of(ScrapIn::SalesNavMessages).to receive(:scroll_down_to)

    driver = double('driver')
    browser = double('browser')
    execute_script = double('execute_script')
    allow(session).to receive(:driver).and_return(driver)
    allow(driver).to receive(:browser).and_return(browser)
    allow(browser).to receive(:execute_script)


    visit_succeed(thread_link)
    allow(session).to receive(:has_selector?).and_return(true)

    create_node_array(message_thread_elements, 3)
    create_node_array(sales_loaded_messages)
    create_conversation(message_thread_elements)

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
      context 'when all the messages have been loaded' do
        it 'puts successfully messages and direction and returns true' do
          result = salesnav_messages_instance.execute(10) do |message, direction|
            print direction
            puts " #{message}"
          end
          expect(result).to be(true)
        end
      end

      context 'when need to load more messages' do
        before do
          create_node_array(bigger_conversation, 10)
          create_conversation(bigger_conversation)
          allow(message_thread).to receive(:all)
            .with(message_thread_elements_css, wait: 5)
            .and_return(message_thread_elements, bigger_conversation)
        end
        it 'puts successfully messages and direction and returns true' do
          result = salesnav_messages_instance.execute(10) { |message, direction| }
          expect(result).to be(true)
        end
      end

      context 'when execute with 0 messages expected' do
        it 'returns true' do
          result = salesnav_messages_instance.execute(0) { |message, direction| }
          expect(result).to be(true)
        end
      end

      context 'when execute with no number of messages argument' do
        it 'returns true' do
          result = salesnav_messages_instance.execute { |message, direction| }
          expect(result).to be(true)
        end
      end
      context 'when execute with negative number of messages argument' do
        it { expect(salesnav_messages_instance.execute(-1000) { |message, direction| }).to be(true) }
      end
    end

    context 'when cannot wait message to appear' do
      context 'when cannot load messages' do
        before { allow(session).to receive(:all).with(sales_loaded_messages_css, wait: 5).and_return([]) }
        it do
          expect { salesnav_messages_instance.execute(1) { |message, direction| } }.to raise_error('Cannot scrap conversation. Timeout !')
        end
      end

      context 'when cannot find the sales_loaded_messages_css' do
        before { has_not_selector(session, sales_loaded_messages_css, wait: 5) }
        it { expect { salesnav_messages_instance.execute(1) { |message, direction| } }.to raise_error(ScrapIn::CssNotFound) }
        it { expect { salesnav_messages_instance.execute(1) { |message, direction| } }.to raise_error(/#{sales_loaded_messages_css}/) }
      end
    end

    context 'when cannot find the sales_message_css' do
      before { has_not_selector(session, sales_messages_css, wait: 5) }
      it { expect { salesnav_messages_instance.execute(1) { |message, direction| } }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { salesnav_messages_instance.execute(1) { |message, direction| } }.to raise_error(/#{sales_messages_css}/) }
    end

    context 'when cannot find the message_thread_css' do
      before { has_not_selector(sales_messages, message_thread_css, wait: 5) }
      it { expect { salesnav_messages_instance.execute(1) { |message, direction| } }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { salesnav_messages_instance.execute(1) { |message, direction| } }.to raise_error(/#{message_thread_css}/) }
    end

    context 'when cannot find the message_thread_elements_css' do
      before { has_not_selector(message_thread, message_thread_elements_css, wait: 5) }
      it { expect { salesnav_messages_instance.execute(1) { |message, direction| } }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { salesnav_messages_instance.execute(1) { |message, direction| } }.to raise_error(/#{message_thread_elements_css}/) }
    end

    context 'when cannot find the content_css' do
      before do
        message_thread_elements.each do |message|
          has_not_selector(message, content_css, wait: 5)
        end
      end
      it { expect { salesnav_messages_instance.execute(1) { |message, direction| } }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { salesnav_messages_instance.execute(1) { |message, direction| } }.to raise_error(/#{content_css}/) }
    end

    context 'when cannot find the sender_css' do
      before do
        message_thread_elements.each do |message|
          has_not_selector(message, sender_css, wait: 2, visible: false)
        end
      end
      it { expect { salesnav_messages_instance.execute(1) { |message, direction| } }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { salesnav_messages_instance.execute(1) { |message, direction| } }.to raise_error(/#{sender_css}/) }
    end

    context 'when have issues to load messages' do
      context 'when cannot find first message to scroll' do
        before { allow(message_thread).to receive(:all).with(message_thread_elements_css, wait: 5).and_return(message_thread_elements, []) }
        it { expect { salesnav_messages_instance.execute(10) { |message, direction| } }.to raise_error('Item does not exist. Cannot scroll!') }
      end
    end
  end
end
