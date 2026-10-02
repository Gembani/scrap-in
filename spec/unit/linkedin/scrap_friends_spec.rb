require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapFriends do
  include CssSelectors::LinkedIn::ScrapFriends
  let(:session) { instance_double('Capybara::Session') }
  let(:subject) { described_class.new(session) }
  let(:connection_url) { 'https://www.linkedin.com/mynetwork/invite-connect/connections/' }

  def friend_node(index)
    friend = instance_double('Capybara::Node::Element', "friend #{index}")
    name = instance_double('Capybara::Node::Element', text: "Friend #{index}")
    connected_on = instance_double('Capybara::Node::Element', text: 'Connected on October 2, 2026')
    link = instance_double('Capybara::Node::Element')
    allow(link).to receive(:[]).with(:href).and_return("https://www.linkedin.com/in/friend-#{index}/")

    has_selector(friend, friend_name_css)
    find(friend, name, friend_name_css)
    has_selector(friend, 'p', text: connected_on_regex)
    find(friend, connected_on, 'p', text: connected_on_regex)
    has_selector(friend, link_css)
    allow(friend).to receive(:first).with(link_css).and_return(link)
    friend
  end

  let(:first_page) { Array.new(10) { |index| friend_node(index) } }
  let(:second_page) { first_page + Array.new(10) { |index| friend_node(index + 10) } }

  before do
    disable_puts
    allow(session).to receive(:visit).with(connection_url)
    has_selector(session, friend_card_css)
    allow(session).to receive(:all).with(friend_card_css, wait: 0).and_return(first_page)
    allow(subject).to receive(:scroll_to)
    allow(subject).to receive(:scroll_workspace_to_bottom)
  end

  describe '.execute' do
    it 'yields name, connection date and url' do
      yielded = []
      expect(subject.execute(1) { |*friend| yielded << friend }).to be(true)
      expect(yielded).to eq([['Friend 0', 'October 2, 2026', 'https://www.linkedin.com/in/friend-0']])
    end

    context 'when more friends than loaded are asked' do
      before do
        loaded = first_page
        allow(subject).to receive(:scroll_workspace_to_bottom) { loaded = second_page }
        allow(session).to receive(:all).with(friend_card_css, wait: 0) { loaded }
      end
      it 'scrolls to load more' do
        names = []
        subject.execute(15) { |name, _time_ago, _url| names << name }
        expect(subject).to have_received(:scroll_workspace_to_bottom).once
        expect(names).to eq(Array.new(15) { |index| "Friend #{index}" })
      end
    end

    context 'when there are no more friends to load' do
      it 'stops at the last friend' do
        count = 0
        expect(subject.execute(15) { count += 1 }).to be(true)
        expect(count).to eq(10)
      end
    end

    context 'when the connections never appear' do
      before { has_not_selector(session, friend_card_css) }
      it { expect(subject.execute(1) {}).to be(false) }
    end

    context 'when the friend name selector was not found' do
      before { has_not_selector(first_page.first, friend_name_css) }
      it { expect { subject.execute(1) {} }.to raise_error(ScrapIn::CssNotFound, /#{Regexp.escape(friend_name_css)}/) }
    end
  end
end
