# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::Invite do
	let(:subject) { described_class }
	let(:session) { instance_double('Capybara::Session') }
	let(:lead_url) { 'lead_url' }
	let(:note) { 'notenotenotenotenote' }
	let(:invite_instance) { subject.new(session, lead_url) }
	let(:buttons_array) { [] }

	
	include CssSelectors::LinkedIn::Invite
	
	before do
		disable_puts_for_class(ScrapIn::LinkedIn::Invite)
		
		# create_node_array(buttons_array, 5)

		allow(session).to receive(:visit).with(lead_url)
		has_selector(session, buttons_css)
		allow(session).to receive(:all).with(buttons_css).and_return(buttons_array)
	end

	describe '.initialize' do
    it { is_expected.to eq ScrapIn::LinkedIn::Invite }
	end
	
	describe '.execute' do
		context 'everything is ok in order to invite someone with a note' do
			it 'succesfully invites someone' do
				result = invite_instance.execute(lead_url, note)
				expect(result).to eq(true)
			end
		end
	end
end