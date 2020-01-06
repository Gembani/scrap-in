# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::Invite do
  let(:subject) { described_class }
  let(:session) { instance_double('Capybara::Session', 'session') }
  let(:lead_url) { 'lead_url' }
  let(:note) { 'Hello, it\'s me. I was wondering if after all these years you\'d like to meet.' }
  let(:invite_instance) { subject.new(session) }
  
  let(:input_note_area) { instance_double('Capybara::Node::Element', 'input_note_area') }
  

  
  include CssSelectors::LinkedIn::Invite
  
  before do
    disable_puts
    allow(session).to receive(:visit)
    
 
    
  end
  
  describe '.execute' do
    let(:add_a_note_button) {  instance_double('Capybara::Node::Element', 'add_a_note_button')}
    let(:note_textarea) {  instance_double('Capybara::Node::Element', 'note_textarea')}
    let(:send_invitation_button) {  instance_double('Capybara::Node::Element', 'send_invitation_button')}
      
    before do 
      has_selector(session, add_a_note_button_css)
      find(session, add_a_note_button, add_a_note_button_css)
      allow(add_a_note_button).to receive(:click)
      
      has_selector(session, note_area_css)
      allow(note_textarea).to receive(:send_keys)
      allow(session).to receive(:find).with(note_area_css).and_return(note_textarea)
       
      
      has_selector(session, send_invitation_button_css)
      allow(session).to receive(:find).with(send_invitation_button_css).and_return(send_invitation_button)
      allow(send_invitation_button).to receive(:click)
      
      has_selector(session, 'span', text: confirmation_text)
      
    end
    context 'click on message button dirrectly' do 
      let(:connect_button) {  instance_double('Capybara::Node::Element', 'connect_button')}

      before do
        has_selector(session, connect_buttons_css)
        find(session, connect_button, connect_buttons_css)
        allow(connect_button).to receive(:click)
        lead_invite_is_not_pending
        expect(invite_instance.execute(lead_url, note)).to eq(true)
      end
      it {
        expect(session).to have_received(:visit).with(lead_url)
      }
      it{
        expect(connect_button).to have_received(:click).with(no_args)
      }
      it{
        expect(add_a_note_button).to have_received(:click).with(no_args)
      }

      it {
        expect(note_textarea).to have_received(:send_keys).with(note)
      }
      it {
        expect(send_invitation_button).to have_received(:click).with(no_args)
      }
    end

    context 'click on message more info and then connect button' do 
      # let(:more_button) {  instance_double('Capybara::Node::Element', 'more_button')}
      let(:connect_in_more_button) {  instance_double('Capybara::Node::Element', 'connect_button')}
      
      before do
        has_not_selector(session, connect_buttons_css)

        has_selector(session, connect_in_more_button_css)
        find(session, connect_in_more_button, connect_in_more_button_css)
        allow(connect_in_more_button).to receive(:click)
        lead_invite_is_not_pending
        expect(invite_instance.execute(lead_url, note)).to eq(true)
      end
      it {
        expect(session).to have_received(:visit).with(lead_url)
      }
      it{
        expect(connect_in_more_button).to have_received(:click).with(no_args)
      }
      it{
        expect(add_a_note_button).to have_received(:click).with(no_args)
      }

      it {
        expect(note_textarea).to have_received(:send_keys).with(note)
      }
      it {
        expect(send_invitation_button).to have_received(:click).with(no_args)
      }
    end

    context 'raise if both don\'t exist' do 
      let(:more_button) {  instance_double('Capybara::Node::Element', 'more_button')}
      let(:connect_in_more_button) {  instance_double('Capybara::Node::Element', 'connect_button')}
      
      before do
        has_not_selector(session, connect_buttons_css)
        has_not_selector(session, css_more_button)
      end
      it {
        expect{invite_instance.execute(lead_url, note)}.to raise_error(ScrapIn::CssNotFound)
      }
    end
  end
end
