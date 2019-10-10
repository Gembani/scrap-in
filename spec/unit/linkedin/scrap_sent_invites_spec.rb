# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapSentInvites do
	let(:scrap_sent_invites) { described_class.new(session) }
	let(:session) { instance_double('Capybara::Session', 'session') }
	let(:visit_url) { 'https://www.linkedin.com/mynetwork/invitation-manager/sent/' }

	let(:item_node) { instance_double('Capybara::Node::Element', 'item') }

	let(:name_string) { Faker::Name.name }

	include CssSelectors::LinkedIn::ScrapSentInvites

	before do
		disable_puts
		disable_script

		allow(session).to receive(:visit).with(visit_url)

		has_selector(session, invitation_list_css)

		count = 0
		50.times do
			has_selector(session,  nth_lead_css(count, invitation: false), wait: 10)
			has_selector(session,  nth_lead_css(count), wait: 3)

			allow(session).to receive(:find).with(nth_lead_css(count)).and_return(item_node)
			allow(item_node).to receive(:native)
			allow(item_node).to receive(:text).and_return(name_string)
			
			count += 1
		end
	end

	xdescribe '.initialize' do
		it { is_expected.to eq ScrapIn::LinkedIn::ScrapSentInvites }
	end

	describe '.execute' do
		context 'normal behavior' do
			it do
				result = scrap_sent_invites.execute do |name|
					expect(name).not_to be_empty
				end
					expect(result).to eq(true)
			end
		end
	end
end