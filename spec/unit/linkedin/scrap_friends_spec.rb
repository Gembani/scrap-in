require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapFriends do
  let(:friends) do
    described_class.new(session)
  end

  let(:session) { instance_double('Capybara::Session') }

  let(:friends_array) { [] }
  let(:name_nodes_array) { [] }
  let(:link_nodes_array) { [] }
  let(:time_ago_nodes_array) { [] }

  let(:names_array) { [] }
  let(:time_agos_array) { [] }
  let(:links_array) { [] }

  include CssSelectors::LinkedIn::ScrapFriends

  before do
    disable_script
    create_node_array(friends_array, 40)
    create_node_array(name_nodes_array, 40)
    create_node_array(time_ago_nodes_array, 40)
    create_node_array(link_nodes_array, 40)

    allow(session).to receive(:visit)
    has_selector(session, nth_friend_css(0)) # use css selector nth_friend_css

    40.times do
      names_array << Faker::Name.name
      links_array << Faker::Internet.url
      time_agos_array << Faker::Time.backward(14, :evening)
    end
    count = 0
    40.times do
      has_selector(session, nth_friend_css(count)) # use css selector nth_friend_css
      allow(session).to receive(:find).with(nth_friend_css(count)).and_return(friends_array[count])

      allow(friends_array[count]).to receive(:native)

      has_selector(session, friend_name_css)
      has_selector(session, time_ago_css)
      has_selector(session, link_css)

      has_selector(friends_array[count], friend_name_css)
      has_selector(friends_array[count], time_ago_css)
      has_selector(friends_array[count], link_css)

      allow(friends_array[count]).to receive(:find).with(friend_name_css).and_return(name_nodes_array[count])
      allow(name_nodes_array[count]).to receive(:text).and_return(names_array[count])

      allow(friends_array[count]).to receive(:find).with(link_css).and_return(link_nodes_array[count])
      allow(link_nodes_array[count]).to receive(:[]).with(:href).and_return(links_array[count])

      allow(friends_array[count]).to receive(:find).with(time_ago_css).and_return(time_ago_nodes_array[count])
      allow(time_ago_nodes_array[count]).to receive(:text).and_return(time_agos_array[count])

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
    context 'the selector for friend name was not found' do
      before do
        count = 0
        40.times do
          has_not_selector(friends_array[count], friend_name_css)
          count += 1
        end
      end
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
      before do
        count = 0
        40.times do
          has_not_selector(friends_array[count], time_ago_css)
          count += 1
        end
      end
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
      before do
        count = 0
        40.times do
          has_not_selector(friends_array[count], link_css)
          count += 1
        end
      end
      it do
        expect { friends.execute { |_name, _time_ago, _link| } }
        .to raise_error(ScrapIn::CssNotFound)
      end
      it do
        expect { friends.execute { |_name, _time_ago, _link| } }
        .to raise_error(/#{link_css}/)
      end
    end
    
        context 'the selector for name was not found' do
          before do
            has_not_selector(session, friend_name_css)
          end
          it do
            friends.search_for_name_and_time_ago(1) do |name, time_ago, link|
              expect(name).to be_empty
            end
          end
        end
    
        context 'the selector for time ago was not found' do
          before do
            has_not_selector(session, time_ago_css)
          end
          it do
            friends.search_for_name_and_time_ago(1) do |name, time_ago, link|
              expect(time_ago).to be_empty
            end
          end
        end

    context 'the selector for link was not found' do
      before do
        has_not_selector(session, link_css)
      end
      it do
        friends.search_for_name_and_time_ago(1) do |name, time_ago, link|
          expect(link).to be_empty
        end
      end
    end

    context 'normal behavior' do
      it do
        count = 0
        result = friends.execute do |name, time_ago, link|
          expect(name).to eq(names_array[count])
          expect(time_ago).to eq(time_agos_array[count])
          expect(link).to eq(links_array[count])
          count += 1
        end
        expect(result).to eq(true)
      end
    end
  end
end
