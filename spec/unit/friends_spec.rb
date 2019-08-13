require 'spec_helper'

RSpec.describe ScrapIn::Friends do
  let(:friends) do
    described_class.new(session)
  end

  let(:session) { instance_double('Capybara::Session') }

  let(:nth_friend_css) { 'nth_friend_css' }
  describe 'Initializer' do
    subject { described_class }
    it { is_expected.to eq ScrapIn::Friends }
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
  end
end
