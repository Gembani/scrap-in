require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapFriends do
  let(:friends) do
    described_class.new(session)
  end

  let(:session) { instance_double('Capybara::Session') }

  let(:nth_friend_css) { 'nth_friend_css' }

  let(:friend) { instance_double('Capybara::Node::Element', 'friend') }
  let(:name_node) { instance_double('Capybara::Node::Element', 'name') }
  let(:link_node) { instance_double('Capybara::Node::Element', 'link') }
  let(:time_ago_node) { instance_double('Capybara::Node::Element', 'time_ago') }

  let(:name_string) { Faker::Name.name }
  let(:link_string) { Faker::Internet.url }
  let(:time_ago_string) { Faker::Time.backward(14, :evening) }

  include CssSelectors::LinkedIn::ScrapFriends

  before do
    disable_script

    allow(session).to receive(:visit)
    has_selector(session, "section.mn-connections > ul >  li:nth-child(1)") # use css selector nth_friend_css

    count = 0
    1.times do
      has_selector(session, "section.mn-connections > ul >  li:nth-child(#{count})") # use css selector nth_friend_css
      allow(session).to receive(:find).with("section.mn-connections > ul >  li:nth-child(1)").and_return(friend)

      allow(friend).to receive(:native)

      has_selector(session, friend_name_css)
      has_selector(session, time_ago_css)
      has_selector(session, link_css)

      has_selector(friend, friend_name_css)
      has_selector(friend, time_ago_css)
      has_selector(friend, link_css)

      allow(friend).to receive(:find).with(friend_name_css).and_return(name_node)
      allow(name_node).to receive(:text).and_return(name_string)

      allow(friend).to receive(:find).with(link_css).and_return(link_node)
      allow(link_node).to receive(:[]).with(:href).and_return(link_string)

      allow(friend).to receive(:find).with(time_ago_css).and_return(time_ago_node)
      allow(time_ago_node).to receive(:text).and_return(time_ago_string)

      allow(friends).to receive(:search_for_name_and_time_ago).with(count).and_yield(
        name_string,
        time_ago_string,
        link_string
      )
      count += 1
    end
  end
  describe 'Initializer' do
    subject { described_class }
    it { is_expected.to eq ScrapIn::LinkedIn::ScrapFriends }
  end

  describe 'instance of described class' do
    subject { friends.instance_variables }
    it { is_expected.to include(:@session) }
    it { is_expected.to include(:@error) }
  end

  describe '.execute' do
    context 'Friends were found on the page' do
      before do
        allow(friends).to receive(:visit_target_page).and_return(true)
        40.times do |i|
          allow(friends).to receive(:search_for_name_and_time_ago).with(i).and_yield(
            Faker::Name.name,
            Faker::Time.backward(14, :evening),
            Faker::Internet.url
          )
        end
      end

      it 'finds one friend' do
        friends.execute(num_times = 1) do |name, time_ago|
          expect(name).not_to be_empty
          expect(time_ago.to_s).not_to be_empty
        end
      end
      it 'finds multiple friends' do
        friends.execute do |name, time_ago|
          expect(name).not_to be_empty
          expect(time_ago.to_s).not_to be_empty
        end
      end
    end

    context 'Friends were not found on the page' do
      before do
        allow(friends).to receive(:nth_friend_css).with(0).and_return(nth_friend_css)
        allow(session).to receive(:visit).with(friends.connections_url)
        allow(session).to receive(:has_selector?).with(nth_friend_css)
      end

      it 'stops the research and return false' do
        friends.execute
        expect(friends.error).not_to be_empty
      end
    end

    context 'the selector for friend name was not found' do
      before { has_not_selector(friends, friend_name_css) }
      it do
        expect { friends.execute { |_name, _thread_link| } }
          .to raise_error(ScrapIn::CssNotFound)
      end
      it do
        expect { friends.execute { |_name, _thread_link| } }
          .to raise_error(/#{friend_name_css}/)
      end
    end

    context 'testtesttest' do
      it { expect(friends.execute).to eq(true)}

      # it 'finds multiple friends' do
      #   friends.execute do |name, time_ago|
      #     expect(name).not_to be_empty
      #     expect(time_ago.to_s).not_to be_empty
      #   end
      # end
    end
  end
end
