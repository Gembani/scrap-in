require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::Threads do
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

	include CssSelectors::LinkedIn::Threads

	before do
		disable_puts

		create_node_array(threads_list_array, 12)
		allow(session).to receive(:visit).with(messages_link)

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

	context 'when num_times is not positive throws error' do
		it { expect{ linkedin_threads_instance.execute(0)  }.to raise_error(ArgumentError) }
	end

	context 'when num_times is 1' do
		it { expect(linkedin_threads_instance.execute(1) { |_name, _thread_link| } ).to eq(true) }
	end

	context 'when num_times is 30' do
		it { expect(linkedin_threads_instance.execute(30) { |_name, _thread_link| } ).to eq(true) }
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