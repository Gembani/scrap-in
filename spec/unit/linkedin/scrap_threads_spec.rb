require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapThreads do
  RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
  let(:subject) do
    described_class
  end

  let(:linkedin_threads_instance) do
    subject.new(session)
  end

  let(:session) { instance_double('Capybara::Session') }
  let(:messages_link) { 'https://www.linkedin.com/messaging/' }
  let(:thread_link) { 'https://www.linkedin.com/messaging/johnsmith' }
  let(:name) { 'John Smith' }
  let(:threads_list) { instance_double('Capybara::Node::Element', 'threads_list') }
  let(:threads_list_2) { instance_double('Capybara::Node::Element', 'threads_list_2') }
  let(:conversation) { instance_double('Capybara::Node::Element', 'conversation') }
  let(:threads_list_array) { [] }

  include CssSelectors::LinkedIn::ScrapThreads

  before do
    disable_puts

    create_node_array(threads_list_array, 12)
    allow(session).to receive(:visit).with(messages_link)
    allow(linkedin_threads_instance).to receive(:scroll_to)
    allow(linkedin_threads_instance).to receive(:last_message).and_return(['<p>See you Wednesday</p>', :incoming])
    count = 0
    12.times do
      has_selector(session, threads_block_css)
      allow(session).to receive(:find).with(threads_block_css).and_return(threads_list)

      has_selector(threads_list, threads_list_css, wait: 5)
      allow(threads_list).to receive(:all).with(threads_list_css, wait: 5).and_return(threads_list_array)

      has_selector(session, threads_block_count_css(count))
      allow(session).to receive(:find).with(threads_block_count_css(count)).and_return(threads_list_2)

      has_selector(threads_list_2, one_thread_css, wait: 5)
      allow(threads_list_2).to receive(:find).with(one_thread_css, wait: 5).and_return(conversation)
      
      allow(conversation).to receive(:text).and_return(name)
      allow(conversation).to receive(:click)

      allow(session).to receive(:current_url).and_return(thread_link)
      count += 1
    end
  end

  context 'when reading the inbox deeply' do
    it 'yields each conversation with its newest message, up to what the list holds' do
      seen = []
      expect(linkedin_threads_instance.execute(30) { |*args| seen << args }).to eq(true)
      expect(seen.size).to eq(12)
      expect(seen.first).to eq([name, thread_link, ['<p>See you Wednesday</p>', :incoming]])
    end

    it 'stops when the block says it has the rest' do
      seen = 0
      linkedin_threads_instance.execute(30) { (seen += 1) == 3 ? :stop : nil }
      expect(seen).to eq(3)
    end

    it 'scrolls the list to load more conversations' do
      allow(linkedin_threads_instance).to receive(:set_limit).and_return(12, 14, 14)
      [12, 13].each do |count|
        has_selector(session, threads_block_count_css(count))
        allow(session).to receive(:find).with(threads_block_count_css(count)).and_return(threads_list_2)
      end
      seen = 0
      linkedin_threads_instance.execute(30) { seen += 1 }
      expect(linkedin_threads_instance).to have_received(:scroll_to).with(threads_list_array.last).twice
      expect(seen).to eq(14)
    end
  end

  describe '#last_message' do
    let(:reader) { subject.new(session) }
    let(:mine) { instance_double('Capybara::Node::Element', 'mine') }
    let(:theirs) { instance_double('Capybara::Node::Element', 'theirs') }
    let(:attachment) { instance_double('Capybara::Node::Element', 'attachment') }
    let(:body) { { 'innerHTML' => '<p>great</p>' } }

    before do
      allow(session).to receive(:has_selector?).with(pane_name_css, text: 'John Smith', wait: 0).and_return(true)
      allow(session).to receive(:all).with(message_items_css, wait: 2).and_return([mine, theirs, attachment])
      allow(attachment).to receive(:first).with(message_body_css, minimum: 0, wait: 0).and_return(nil)
      allow(theirs).to receive(:first).with(message_body_css, minimum: 0, wait: 0).and_return(body)
      allow(theirs).to receive(:first).with(message_sender_css, minimum: 0, wait: 0)
                                      .and_return({ class: 'msg-s-event-listitem msg-s-event-listitem--other' })
    end

    it 'reads the newest message with text, and who wrote it' do
      expect(reader.last_message('John Smith')).to eq(['<p>great</p>', :incoming])
    end

    it 'says nothing while the pane still shows another conversation' do
      allow(session).to receive(:has_selector?).with(pane_name_css, text: 'John Smith', wait: 0).and_return(false)
      expect(reader.last_message('John Smith')).to be_nil
    end
  end

  context 'when num_times is not positive throws error' do
    it { expect { linkedin_threads_instance.execute(0) }.to raise_error(ArgumentError) }
  end

  context 'when num_times is 1' do
    it { expect(linkedin_threads_instance.execute(1) { |_name, _thread_link| }).to eq(true) }
  end

  context 'when num_times is 30' do
    it { expect(linkedin_threads_instance.execute(30) { |_name, _thread_link| }).to eq(true) }
  end

  context 'the selector for threads block count was not found' do
    before do
      count = 0
      12.times do
        has_not_selector(session, threads_block_count_css(count))
        count += 1
      end
    end
    it do
      count = 0
      12.times do
        expect { linkedin_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(ScrapIn::CssNotFound)
        count += 1
      end
    end
    it do
      count = 0
      12.times do
        expect { linkedin_threads_instance.execute { |_name, _thread_link| } }
          .to raise_error(/#{threads_block_css}/)
        count += 1
      end
    end
  end

  context 'the selector for threads block was not found' do
    before { has_not_selector(session, threads_block_css) }
    it do
      expect { linkedin_threads_instance.execute { |_name, _thread_link| } }
        .to raise_error(ScrapIn::CssNotFound)
    end
    it do
      expect { linkedin_threads_instance.execute { |_name, _thread_link| } }
        .to raise_error(/#{threads_block_css}/)
    end
  end
  
  context 'the selector for one thread was not found' do
    before { has_not_selector(threads_list_2, one_thread_css, wait: 5) }
    it do
      expect { linkedin_threads_instance.execute { |_name, _thread_link| } }
        .to raise_error(ScrapIn::CssNotFound)
    end
    it do
      expect { linkedin_threads_instance.execute { |_name, _thread_link| } }
        .to raise_error(/#{one_thread_css}/)
    end
  end
end
