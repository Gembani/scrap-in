# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::SalesNavigator::Threads do
  let(:subject) do
    described_class
  end

  let(:sales_nav_threads_instance) do
    subject.new(session)
  end

  def node_array(size); end

  let(:session) { instance_double('Capybara::Session') }
  let(:threads_list) { instance_double('Capybara::Node::Element') }
  let(:element) { instance_double('Capybara::Node::Element') }
  let(:element_2) { instance_double('Capybara::Node::Element') }
  let(:element_3) { instance_double('Capybara::Node::Element') }
  let(:element_4) { instance_double('Capybara::Node::Element') }
  let(:element_5) { instance_double('Capybara::Node::Element') }
  let(:element_6) { instance_double('Capybara::Node::Element') }
  let(:element_7) { instance_double('Capybara::Node::Element') }
  let(:element_8) { instance_double('Capybara::Node::Element') }
  let(:element_9) { instance_double('Capybara::Node::Element') }
  let(:element_10) { instance_double('Capybara::Node::Element', 'element_10') }
  let(:element_11) { instance_double('Capybara::Node::Element', 'element_11')}
  let(:element_12) { instance_double('Capybara::Node::Element', 'element_12')}
  let(:threads_list_elements) { instance_double('Capybara::Node::Element') }
  let(:element_14) { instance_double('Capybara::Node::Element') }


  let(:element_array_1) do
    [
      element
    ]
  end
  let(:element_array_2) do
    [
      element,
      element_2,
      element_3
    ]
  end
  let(:element_array_3) do
    [
      element_4,
      element_5,
      element_6
    ]
  end
  let(:threads_list_array) { [] }
  let(:element_array_5) do
    [
      element_10,
      element_11,
      element_12
    ]
  end
  let(:element_array_6) do
    [
      element_14
    ]
  end

  include CssSelectors::Threads
  before do
    disable_puts_for_class(ScrapIn::SalesNavigator::Threads)
    disable_sleep_for_class(ScrapIn::SalesNavigator::Threads)

    has_selector(session, threads_access_button_css, wait: 5)
    allow(session).to receive(:has_selector?).and_return(true)

    allow(session).to receive(:has_selector?).with(message_css, wait: 5).and_return(true)
    allow(session).to receive(:all).with(threads_access_button_css, wait: 5).and_return(element_array_1)

    allow(element).to receive(:click)

    allow(session).to receive(:has_selector?).with(message_css, wait: 5).and_return(true)
    allow(session).to receive(:all).with(message_css, wait: 5).and_return(element_array_2)

    allow(session).to receive(:has_selector?).with(threads_list_css).and_return(true)
    allow(session).to receive(:find).with(threads_list_css).and_return(threads_list)

    allow(threads_list).to receive(:has_selector?).with(loaded_threads_css, wait: 5).and_return(true)
    allow(threads_list).to receive(:all).with(loaded_threads_css, wait: 5).and_return(element_array_3)

    allow(threads_list).to receive(:has_selector?).with(threads_list_elements_css, wait: 5).and_return(true)
    allow(threads_list).to receive(:all).with(threads_list_elements_css, wait: 5).and_return(threads_list_array)

    create_node_array(threads_list_array, 3)
    element_array_5
    count = 0
    threads_list_array.each do |threads_list_elements|
      allow(threads_list_elements).to receive(:has_selector?).with(thread_name_css, wait: 5).and_return(true)
      allow(threads_list_elements).to receive(:find).with(thread_name_css, wait: 5).and_return(element_array_5[count])
      allow(element_array_5[count]).to receive(:text)
      allow(element_array_5[count]).to receive(:click)
      allow(session).to receive(:current_url).and_return('Thread url')
      count += 1
    end
  end

  describe '.initialize' do
    it { is_expected.to eq ScrapIn::SalesNavigator::Threads }
  end

  describe '.execute' do
    context 'everything is ok in order to scrap threads links' do
      it 'scraps successfully threads and names' do
        result = sales_nav_threads_instance.execute { |_name, _thread_link| }
        expect(result).to be(true)
      end
    end

    context 'num_times eq 0' do
      it 'scraps nothing and returns' do
        result = sales_nav_threads_instance.execute(num_times = 0) { |_name, _thread_link| }
        expect(result).to be(true)
      end
    end

    context 'num_times eq 1' do
      it 'scraps one thread' do
        result = sales_nav_threads_instance.execute(num_times = 1) { |_name, _thread_link| }
        expect(result).to be(true)
      end
    end

    context 'wait_messages_page_to_load loop receive only one node at every loop' do
      before do
        allow(session).to receive(:all).with(message_css, wait: 5).and_return(element_array_6)
      end
      it { expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }.to raise_error('Cannot scrap conversation. Timeout !') }
    end

    context 'the selector for threads list was not found' do
      before { has_not_selector(session, threads_list_css) }
      it { expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }.to raise_error(/#{threads_list_css}/) }
    end

    context 'the selector for threads list elements was not found' do
      before { has_not_selector(threads_list, threads_list_elements_css, wait: 5) }
      it { expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }.to raise_error(/#{threads_list_elements_css}/) }
    end

    context 'the selector for loaded threads was not found' do
      before { has_not_selector(threads_list, loaded_threads_css, wait: 5) }
      it { expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }.to raise_error(/#{loaded_threads_css}/) }
    end

    context 'the selector for thread name was not found' do
      before do
        threads_list_array.each do |threads_list_elements|
          has_not_selector(threads_list_elements, thread_name_css, wait: 5)
        end
      end
      it { expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }.to raise_error(/#{thread_name_css}/) }
    end

    context 'the selector for message list was not found' do
      before { has_not_selector(session, message_css, wait: 5) }
      it { expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }.to raise_error(/#{message_css}/) }
    end

    context 'the selector for thread access button was not found' do
      before { has_not_selector(session, threads_access_button_css, wait: 5) }
      it { expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }.to raise_error(ScrapIn::CssNotFound) }
      it { expect { sales_nav_threads_instance.execute { |_name, _thread_link| } }.to raise_error(/#{threads_access_button_css}/) }
    end
  end
end
