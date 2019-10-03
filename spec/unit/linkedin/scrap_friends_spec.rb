require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapFriends do
  let(:friends) do
    described_class.new(session)
  end

  let(:session) { instance_double('Capybara::Session') }

  let(:friend) { instance_double('Capybara::Node::Element', 'friend') }
  let(:name_node) { instance_double('Capybara::Node::Element', 'name') }
  let(:link_node) { instance_double('Capybara::Node::Element', 'link') }
  let(:time_ago_node) { instance_double('Capybara::Node::Element', 'time_ago') }

  # let(:name_string) { Faker::Name.name }
  # let(:link_string) { Faker::Internet.url }
  # let(:time_ago_string) { Faker::Time.backward(14, :evening) }
  let(:names_array) { [] }
  let(:time_agos_array) { [] }
  let(:links_array) { [] }

  include CssSelectors::LinkedIn::ScrapFriends

  before do
    disable_script

    allow(session).to receive(:visit)
    # has_selector(session, nth_friend_css(0)) # use css selector nth_friend_css

    count = 0
    40.times do
      has_selector(session, nth_friend_css(count)) # use css selector nth_friend_css
      allow(session).to receive(:find).with(nth_friend_css(count)).and_return(friend)

      allow(friend).to receive(:native)

      has_selector(session, friend_name_css)
      has_selector(session, time_ago_css)
      has_selector(session, link_css)

      has_selector(friend, friend_name_css)
      has_selector(friend, time_ago_css)
      has_selector(friend, link_css)

      allow(friend).to receive(:find).with(friend_name_css).and_return(name_node)
      name = Faker::Name.name
      allow(name_node).to receive(:text).and_return(name)
      names_array << name

      allow(friend).to receive(:find).with(link_css).and_return(link_node)
      link = Faker::Internet.url
      allow(link_node).to receive(:[]).with(:href).and_return(link)
      links_array << link

      allow(friend).to receive(:find).with(time_ago_css).and_return(time_ago_node)
      time_ago = Faker::Time.backward(14, :evening)
      allow(time_ago_node).to receive(:text).and_return(time_ago)
      time_agos_array << time_ago

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
      before { has_not_selector(session, friend_name_css) }
      it do
        expect { friends.execute { |_name, _thread_link| } }
          .to raise_error(ScrapIn::CssNotFound)
      end
      it do
        expect { friends.execute { |_name, _thread_link| } }
          .to raise_error(/#{friend_name_css}/)
      end
    end

    context 'the selector for time ago was not found' do
      before { has_not_selector(session, time_ago_css) }
      it do
        expect { friends.execute { |_name, _thread_link| } }
          .to raise_error(ScrapIn::CssNotFound)
      end
      it do
        expect { friends.execute { |_name, _thread_link| } }
          .to raise_error(/#{time_ago_css}/)
      end
    end

    context 'the selector for link was not found' do
      before { has_not_selector(session, link_css) }
      it do
        expect { friends.execute { |_name, _time_ago, _link| } }
          .to raise_error(ScrapIn::CssNotFound)
      end
      it do
        expect { friends.execute { |_name, _time_ago, _link| } }
          .to raise_error(/#{link_css}/)
      end
    end

    context 'the selector for friend name was not found' do
      before { has_not_selector(friends, friend_name_css) }
      it do
        expect { friends.execute { |_name, _time_ago, _link| } }
          .to raise_error(ScrapIn::CssNotFound)
      end
      it do
        expect { friends.execute { |_name, _time_ago, _link| } }
          .to raise_error(/#{friend_name_css}/)
      end
    end

    context 'the selector for friend name was not found' do
      before { has_not_selector(friends, time_ago_css) }
      it do
        expect { friends.execute { |_name, _time_ago, _link| } }
          .to raise_error(ScrapIn::CssNotFound)
      end
      it do
        expect { friends.execute { |_name, _time_ago, _link| } }
          .to raise_error(/#{time_ago_css}/)
      end
    end

    context 'the selector for friend name was not found' do
      before { has_not_selector(friends, link_css) }
      it do
        expect { friends.execute { |_name, _time_ago, _link| } }
          .to raise_error(ScrapIn::CssNotFound)
      end
      it do
        expect { friends.execute { |_name, _time_ago, _link| } }
          .to raise_error(/#{link_css}/)
      end
    end

    context 'testtesttest' do
      it do
        count = 0
        40.times do
          result = friends.execute(40) do |name, time_ago, link|
            # expect(name).to eq(names_array[count])
            # expect(time_ago).to eq(time_agos_array[count])
            # expect(link).to eq(links_array[count])
            count += 1
          end
        end
        expect(result).to eq(true)
      end
    end
  end
end
