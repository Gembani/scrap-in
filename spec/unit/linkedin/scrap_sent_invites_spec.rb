require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapSentInvites do
  include CssSelectors::LinkedIn::ScrapSentInvites
  let(:session) { instance_double('Capybara::Session') }
  let(:subject) { described_class.new(session) }

  def invitation_node(index, name = "Lead #{index}")
    invitation = instance_double('Capybara::Node::Element', "invitation #{index}")
    name_node = instance_double('Capybara::Node::Element', text: name)
    link = instance_double('Capybara::Node::Element')
    allow(link).to receive(:[]).with(:href).and_return("https://www.linkedin.com/in/lead-#{index}/")

    has_selector(invitation, lead_name_css)
    allow(invitation).to receive(:first).with(lead_name_css).and_return(name_node)
    has_selector(invitation, lead_link_css)
    allow(invitation).to receive(:first).with(lead_link_css).and_return(link)
    invitation
  end

  let(:first_page) { Array.new(10) { |index| invitation_node(index) } }

  before do
    allow(session).to receive(:visit).with(subject.target_page)
    has_selector(session, invitation_css)
    allow(session).to receive(:all).with(invitation_css, wait: 0).and_return(first_page)
    allow(subject).to receive(:scroll_to)
    allow(subject).to receive(:scroll_workspace_to_bottom)
  end

  it 'yields the url and the name of invited leads' do
    yielded = []
    subject.execute(2) { |url, name| yielded << [url, name] }
    expect(yielded).to eq([['https://www.linkedin.com/in/lead-0/', 'Lead 0'], ['https://www.linkedin.com/in/lead-1/', 'Lead 1']])
    expect(subject.invited_leads).to eq(['Lead 0', 'Lead 1'])
  end

  context 'when more invitations than loaded are asked' do
    let(:second_page) { first_page + Array.new(5) { |index| invitation_node(index + 10) } }
    before do
      loaded = first_page
      allow(subject).to receive(:scroll_workspace_to_bottom) { loaded = second_page }
      allow(session).to receive(:all).with(invitation_css, wait: 0) { loaded }
    end
    it 'scrolls to load more and stops when there are no more' do
      count = 0
      subject.execute(50) { count += 1 }
      expect(subject).to have_received(:scroll_workspace_to_bottom).at_least(:once)
      expect(count).to eq(15)
    end
  end

  context 'when an invitation has no name' do
    let(:first_page) { [invitation_node(0, ''), invitation_node(1)] }
    it 'skips it' do
      names = []
      subject.execute(2) { |_url, name| names << name }
      expect(names).to eq(['Lead 1'])
    end
  end

  context 'when the invitation list is not found' do
    before { has_not_selector(session, invitation_css) }
    it { expect(subject.execute(1) {}).to be_nil }
  end
end
