require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::Invite do
  include CssSelectors::LinkedIn::Invite
  let(:session) { instance_double('Capybara::Session', 'session') }
  let(:subject) { described_class.new(session) }
  let(:lead_url) { 'https://www.linkedin.com/in/lead/' }
  let(:note) { 'Hello, it\'s me.' }

  let(:top_card) { instance_double('Capybara::Node::Element', 'top_card') }
  let(:connect_button) { instance_double('Capybara::Node::Element', 'connect_button', click: true) }
  let(:modal_host) { instance_double('Capybara::Node::Element', 'modal_host') }
  let(:shadow_root) { instance_double('Capybara::Node::Element', 'shadow_root') }
  let(:modal) { instance_double('Capybara::Node::Element', 'modal') }
  let(:note_area) { instance_double('Capybara::Node::Element', 'note_area', send_keys: true) }
  let(:modal_buttons) do
    [send_without_note_button_css, add_a_note_button_css, send_invitation_button_css, dismiss_button_css]
      .to_h { |css| [css, instance_double('Capybara::Node::Element', css, click: true)] }
  end

  before do
    disable_puts
    allow(session).to receive(:visit)
    has_selector(session, top_card_css, wait: 10)
    find(session, top_card, top_card_css, wait: 10)
    allow(top_card).to receive(:has_selector?).with(pending_css, wait: 1).and_return(false, true)
    has_selector(top_card, connect_button_css, wait: 1)
    find(top_card, connect_button, connect_button_css)

    has_selector(session, modal_host_css, visible: :all)
    find(session, modal_host, modal_host_css, visible: :all)
    allow(modal_host).to receive(:shadow_root).and_return(shadow_root)
    has_selector(shadow_root, modal_css, wait: 5)
    find(shadow_root, modal, modal_css, wait: 5)

    modal_buttons.each do |css, button|
      has_selector(modal, css)
      find(modal, button, css)
    end
    has_selector(modal, note_area_css, wait: 2)
    find(modal, note_area, note_area_css)
    allow(modal).to receive(:text).and_return('Add a note to your invitation?')
    all(top_card, [paragraph('Jane Doe'), paragraph('· 2nd')], 'p')
  end

  def paragraph(text)
    instance_double('Capybara::Node::Element', text, text: text)
  end

  context 'when the invitation is already pending' do
    before { allow(top_card).to receive(:has_selector?).with(pending_css, wait: 1).and_return(true) }
    it 'does nothing' do
      expect(subject.execute(lead_url)).to be(true)
      expect(connect_button).not_to have_received(:click)
      expect(subject.status).to eq(:already_pending)
    end
  end

  context 'when the lead is already a connection' do
    before { all(top_card, [paragraph('Jane Doe'), paragraph('· 1st')], 'p') }
    it 'does not invite' do
      expect(subject.execute(lead_url)).to be(false)
      expect(connect_button).not_to have_received(:click)
      expect(subject.status).to eq(:already_connected)
    end
  end

  context 'when the weekly invitation limit is reached' do
    before { allow(modal).to receive(:text).and_return("You've reached the weekly invitation limit") }
    it 'dismisses the modal' do
      expect(subject.execute(lead_url)).to be(false)
      expect(modal_buttons[dismiss_button_css]).to have_received(:click)
      expect(modal_buttons[send_without_note_button_css]).not_to have_received(:click)
      expect(subject.status).to eq(:limit_reached)
    end
  end

  context 'when no personalized note is left' do
    before { has_not_selector(modal, note_area_css, wait: 2) }
    it 'does not send without the note' do
      expect(subject.execute(lead_url, note)).to be(false)
      expect(modal_buttons[send_invitation_button_css]).not_to have_received(:click)
      expect(modal_buttons[send_without_note_button_css]).not_to have_received(:click)
      expect(modal_buttons[dismiss_button_css]).to have_received(:click)
      expect(subject.status).to eq(:note_unavailable)
    end
  end

  context 'when the invitation is not confirmed' do
    before { allow(top_card).to receive(:has_selector?).with(pending_css, wait: 1).and_return(false) }
    it 'reports it' do
      expect(subject.execute(lead_url)).to be(false)
      expect(subject.status).to eq(:not_confirmed)
    end
  end

  context 'without a note' do
    before { @result = subject.execute(lead_url) }
    it { expect(session).to have_received(:visit).with(lead_url) }
    it { expect(connect_button).to have_received(:click) }
    it { expect(modal_buttons[send_without_note_button_css]).to have_received(:click) }
    it { expect(modal_buttons[add_a_note_button_css]).not_to have_received(:click) }
    it('confirms the invitation is pending') { expect(@result).to be(true) }
    it { expect(subject.status).to eq(:sent) }
  end

  context 'with a note' do
    before { subject.execute(lead_url, note) }
    it { expect(modal_buttons[add_a_note_button_css]).to have_received(:click) }
    it { expect(note_area).to have_received(:send_keys).with(note) }
    it { expect(modal_buttons[send_invitation_button_css]).to have_received(:click) }
  end

  context 'when send is false' do
    before { subject.execute(lead_url, note, false) }
    it { expect(note_area).to have_received(:send_keys).with(note) }
    it { expect(modal_buttons[send_invitation_button_css]).not_to have_received(:click) }
    it { expect(modal_buttons[dismiss_button_css]).to have_received(:click) }
    it { expect(subject.status).to eq(:prepared) }
  end

  context 'when the connect button is in the More menu' do
    let(:more_button) { instance_double('Capybara::Node::Element', 'more_button', click: true) }
    let(:connect_item) { instance_double('Capybara::Node::Element', 'connect_item', click: true) }
    before do
      has_not_selector(top_card, connect_button_css, wait: 1)
      has_selector(top_card, 'button', text: more_button_text)
      find(top_card, more_button, 'button', text: more_button_text)
      has_selector(session, menu_item_css, text: /\A#{connect_text}\z/)
      find(session, connect_item, menu_item_css, text: /\A#{connect_text}\z/)
      subject.execute(lead_url)
    end
    it { expect(more_button).to have_received(:click) }
    it { expect(connect_item).to have_received(:click) }
    it { expect(modal_buttons[send_without_note_button_css]).to have_received(:click) }
  end

  context 'when there is no connect button at all' do
    before do
      has_not_selector(top_card, connect_button_css, wait: 1)
      has_not_selector(top_card, 'button', text: more_button_text)
    end
    it { expect { subject.execute(lead_url) }.to raise_error(ScrapIn::CssNotFound) }
  end
end
