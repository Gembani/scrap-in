# # frozen_string_literal: true

# require 'spec_helper'

# RSpec.describe ScrapIn::SalesNavThreads do
# 	let(:subject) do
# 		described_class
# 	end

# 	let(:sales_nav_threads_instance) do
# 		subject.new(session)
# 	end

# 	def node_array(size)
		
# 	end

# 	let(:session) { instance_double('Capybara::Session') }
# 	let(:element){ instance_double('Capybara::Node::Element') }
# 	let(:element_2){ instance_double('Capybara::Node::Element') }
# 	let(:element_3){ instance_double('Capybara::Node::Element') }
# 	let(:element_array_1) do
# 		[
# 			element,
# 		]
# 	end
# 	let(:element_array_2) do
# 		[
# 			element,
# 			element_2,
# 			element_3
# 		]
# 	end

# 	include CssSelectors::SalesNavThreads
# 	before do
# 		# disable_puts_for_class(ScrapIn::SalesNavThreads)
# 		# Click messages button to access all threads
# 		# allow(session).to receive(:has_selector?).with(threads_access_button_css, wait: 5).and_return(true)
# 		has_selector(session, threads_access_button_css, wait: 5)

# 		allow(session).to receive(:has_selector?).with(message_css, wait: 5).and_return(true)
# 		allow(session).to receive(:all).with(threads_access_button_css, wait: 5).and_return(element_array_1)

# 		allow(element).to receive(:click)

# 		allow(session).to receive(:has_selector?).with(message_css, wait: 5).and_return(true)
# 		allow(session).to receive(:all).with(message_css, wait: 5).and_return(element_array_1, element_array_2)
# 	end

# 	describe '.initialize' do
# 		it { is_expected.to eq ScrapIn::SalesNavThreads }
# 	end

# 	describe '.execute' do
#     context 'everything is ok in order to scrap threads links' do
# 			it 'scraps successfully threads and names' do
#         result = sales_nav_threads_instance.execute(num_times = 0)
#         expect(result).to be(true)
#       end
#     end
# 	end
# end