# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::Invite do
	let(:subject) { described_class }
	let(:session) { instance_double('Capybara::Session', 'session') }
	let(:lead_url) { 'lead_url' }
	let(:note) { 'Hello, it\'s me. I was wondering if after all these years you\'d like to meet.' }
	let(:invite_instance) { subject.new(session, lead_url) }
	let(:buttons_array) { [] }
	let(:add_a_note_array) { [] }
	let(:send_invitation_array) { [] }
	let(:more_buttons_array) { [] }
	let(:buttons_popup_array) { [] }
	let(:input_note_area) { instance_double('Capybara::Node::Element', 'input_note_area') }
	

	
	include CssSelectors::LinkedIn::Invite
	
	before do
		disable_puts

		create_node_array(buttons_array, 5, 'buttons')
		create_node_array(add_a_note_array, 5, 'add_a_note')
		create_node_array(send_invitation_array, 5, 'send_invitation')
		create_node_array(more_buttons_array, 5, 'more buttons')

		has_selector(session, buttons_css)
		has_selector(session, connect_in_more_button_css, visible: false)
		has_selector(session, note_area_css)
		has_selector(session, 'span', text: confirmation_text)

		allow(session).to receive(:visit).with(lead_url)
		allow(session).to receive(:all).with(buttons_css).and_return(buttons_array, add_a_note_array, send_invitation_array)
		
		buttons_array.each do | button |
			allow(button).to receive(:text).and_return('Connect')
			allow(button).to receive(:click)
		end

		add_a_note_array.each do | button |
			allow(button).to receive(:text).and_return('Add a note')
			allow(button).to receive(:click)
		end

		send_invitation_array.each do | button |
			allow(button).to receive(:text).and_return('Send invitation')
			allow(button).to receive(:click)
		end
		
		more_buttons_array.each do | button |
			allow(button).to receive(:text).and_return('Connect')
			allow(button).to receive(:click)
		end

		# allow(session).to receive(:all).with(buttons_css).and_return(buttons_popup_array)

		allow(session).to receive(:all).with(connect_in_more_button_css, visible: false).and_return(more_buttons_array)
		# allow(more_buttons_array[3]).to receive(:click)
		
		allow(session).to receive(:find).with(note_area_css).and_return(input_note_area)
		allow(input_note_area).to receive(:send_keys)

		allow(session).to receive(:find).with('span', text: confirmation_text).and_return(true)

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

		context 'everything is ok in order to invite someone without a note' do
			it { expect(invite_instance.execute(lead_url)).to eq(true) }
		end
		
		context 'everything is ok in order to invite someone without a note' do
			before do
				invite_instance.execute(lead_url)
			end
			it { expect(input_note_area).to have_received(:send_keys) }
		end

		context 'the confirmation message was not found' do
			before { has_not_selector(session, 'span', text: confirmation_text) }
			it 'did not send the invitation' do
				expect { invite_instance.execute(lead_url, note) }.to raise_error(ScrapIn::CssNotFound)
			end
		end
		
		context 'the selector for note area was not found' do
      before { has_not_selector(session, note_area_css) }
      it do
        expect { invite_instance.execute(lead_url, note) }
          .to raise_error(ScrapIn::CssNotFound)
      end
      it do
        expect { invite_instance.execute(lead_url, note) }
          .to raise_error(/#{note_area_css}/)
      end
		end
	end
end