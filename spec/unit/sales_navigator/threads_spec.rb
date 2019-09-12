# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::SalesNavigator::Threads do
  let(:subject) do
    described_class
  end

  let(:sales_nav_threads_instance) do
    subject.new(session)
  end

  let(:session) { instance_double('Capybara::Session') }
  let(:threads_list) { instance_double('Capybara::Node::Element') }
  let(:threads_list_elements) { instance_double('Capybara::Node::Element') }
  let(:thread_access_button_array) { [] }
  let(:message_array) { [] }
  let(:loaded_threads_array) { [] }
  let(:threads_list_array) { [] }
  let(:thread_name_array) { [] }
  let(:one_message_array) { [] }
  let(:thread_names) do
    [
      'Thread name 1',
      'Thread name 2',
      'Thread name 3'
    ]
  end

  let(:names_array) do
    [
      'Name 1',
      'Name 2',
      'Name 3'
    ]
  end


  include CssSelectors::SalesNavigator::Threads
  before do
    disable_puts_for_class

    has_selector(session, threads_access_button_css, wait: 5)
    create_node_array(thread_access_button_array)
    create_node_array(message_array, 3)
    create_node_array(loaded_threads_array, 3)
    create_node_array(thread_name_array, 3)
    create_node_array(one_message_array)

    has_selector(session, message_css, wait: 5)

    allow(session).to receive(:all).with(threads_access_button_css, wait: 5).and_return(thread_access_button_array)

    allow(thread_access_button_array[0]).to receive(:click)

    has_selector(session, message_css, wait: 5)
    allow(session).to receive(:all).with(message_css, wait: 5).and_return(message_array)

    has_selector(session, threads_list_css)

    find(session, threads_list, threads_list_css)

    has_selector(threads_list, loaded_threads_css, wait: 5)
    allow(threads_list).to receive(:all).with(loaded_threads_css, wait: 5).and_return(loaded_threads_array)

    has_selector(threads_list, threads_list_elements_css, wait: 5)
    allow(threads_list).to receive(:all).with(threads_list_elements_css, wait: 5).and_return(threads_list_array)

    create_node_array(threads_list_array, 3)
    # thread_name_array
    count = 0
    threads_list_array.each do |threads_list_elements|
      has_selector(threads_list_elements, thread_name_css, wait: 5)
      allow(threads_list_elements).to receive(:find).with(thread_name_css, wait: 5).and_return(thread_name_array[count])
      allow(thread_name_array[count]).to receive(:text).and_return(names_array[count])
      allow(thread_name_array[count]).to receive(:click)
      count += 1
    end
    allow(session).to receive(:current_url).and_return(*thread_names)
  end

  describe '.initialize' do
    it { is_expected.to eq ScrapIn::SalesNavigator::Threads }
  end

  describe '.execute' do
    context 'when everything is ok in order to scrap threads links' do
      it 'scraps successfully threads and names' do
        count = 0
        result = sales_nav_threads_instance.execute do |name, thread_link| 
          expect(thread_link).to eq(thread_names[count])
          expect(name).to eq(names_array[count])
          count += 1
        end
        expect(result).to be(true)
      end
    end

    context 'num_times eq 0' do
      it 'scraps nothing and returns' do
        result = sales_nav_threads_instance.execute(0) { |_name, _thread_link| }
        expect(result).to be(true)
      end
    end

    context 'num_times eq 1' do
      it 'scraps one thread' do
        count = 0
        result = sales_nav_threads_instance.execute(1) do |name, thread_link| 
          expect(thread_link).to eq(thread_names[count])
          expect(name).to eq(names_array[count])
          count += 1
        end
        expect(result).to be(true)
      end
    end

    context 'wait_messages_page_to_load loop receive only one node at every loop' do
      before do
        allow(session).to receive(:all).with(message_css, wait: 5).and_return(one_message_array)
      end
      it {
        expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error('Cannot scrap conversation. Timeout !')
      }
    end

    context 'the selector for threads list was not found' do
      before { has_not_selector(session, threads_list_css) }
      it do
        expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(ScrapIn::CssNotFound)
      end
      it do
        expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(/#{threads_list_css}/)
      end
    end

    context 'the selector for threads list elements was not found' do
      before { has_not_selector(threads_list, threads_list_elements_css, wait: 5) }
      it {
        expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(ScrapIn::CssNotFound)
      }
      it {
        expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(/#{threads_list_elements_css}/)
      }
    end

    context 'the selector for loaded threads was not found' do
      before { has_not_selector(threads_list, loaded_threads_css, wait: 5) }
      it {
        expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(ScrapIn::CssNotFound)
      }
      it {
        expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(/#{loaded_threads_css}/)
      }
    end

    context 'the selector for thread name was not found' do
      before do
        threads_list_array.each do |threads_list_elements|
          has_not_selector(threads_list_elements, thread_name_css, wait: 5)
        end
      end
      it {
        expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(ScrapIn::CssNotFound)
      }
      it {
        expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(/#{thread_name_css}/)
      }
    end

    context 'the selector for message list was not found' do
      before { has_not_selector(session, message_css, wait: 5) }
      it {
        expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(ScrapIn::CssNotFound)
      }
      it {
        expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(/#{message_css}/)
      }
    end

    context 'the selector for thread access button was not found' do
      before { has_not_selector(session, threads_access_button_css, wait: 5) }
      it {
        expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(ScrapIn::CssNotFound)
      }
      it {
        expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(/#{threads_access_button_css}/)
      }
    end
  end
end
