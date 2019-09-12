require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::Threads do
	let(:subject) do
		described_class
	end

	let(:linkedin_threads_instance) do
		subject.new(session)
	end

	let(:session) { instance_double('Capybara::Session') }
	let(:messages_link) { 'https://www.linkedin.com/messaging/' }
	let(:threads_block_array) { [] }
	let(:item_array) { [] }

	include CssSelectors::LinkedIn::Threads

	before do
		create_node_array(threads_block_array, 3)
		create_node_array(item_array, 3)

		allow(session).to receive(:visit).with(messages_link)

		has_selector(session, threads_block_css)
		allow(session).to receive(:all).with(threads_block_css).and_return(threads_block_array)

		has_selector(session, threads_block_count_css
		allow(session).to receive(:all).with(threads_block_count_css(12)).and_return(item_array)
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
		before { has_not_selector(session, one_thread_css) }
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