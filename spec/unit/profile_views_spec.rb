require 'spec_helper'

RSpec.describe ScrapIn::ProfileViews do
  include Tools
  let(:profile_views) do
    described_class.new(session)
  end

  let(:session) { instance_double('Capybara::Session') }

  let(:target_page) { Faker::Internet.url }
  include CssSelectors::ProfileViews
  describe 'Initializer' do
    subject { described_class }
    it { is_expected.to eq ScrapIn::ProfileViews }
  end

  describe 'instance of described class' do
    subject { profile_views.instance_variables }
    it { is_expected.to include(:@session) }
    it { is_expected.to include(:@profile_viewed_by) }
  end

  describe '.execute' do
    before do
      allow_any_instance_of(ScrapIn::ProfileViews).to receive(:scroll_to)
      allow(session).to receive(:visit).and_return(true)
      allow(session).to receive(:has_selector?).with(viewers_list_css).and_return(true)

      50.times do |count|
        allow(session).to receive(:has_selector?).with(public_profile_css(count + 1), wait: 1).and_return(true)

        profile_item = instance_double(Capybara::Node::Element)
        name_item = instance_double(Capybara::Node::Element)

        allow(profile_item).to receive(:has_selector?).with(name_css).and_return(true)
        allow(profile_item).to receive(:find).with(name_css).and_return(name_item)
        allow(name_item).to receive(:text).and_return("name #{count + 1}")

        allow(session).to receive(:find).with(public_profile_css(count + 1), wait: 1).and_return(profile_item)

        time_ago_item = instance_double(Capybara::Node::Element)
        allow(time_ago_item).to receive(:text).and_return("time_ago#{count + 1}")
        allow(profile_item).to receive(:has_selector?).with(time_ago_css).and_return(true)
        allow(profile_item).to receive(:find).with(time_ago_css).and_return(time_ago_item)
      end
    end
    context 'Everything was found (up to 50 profiles)' do
      it 'finds one lead' do
        profile_views.execute(num_times = 1) do |name, time_ago|
          expect(name).not_to be_empty
          expect(time_ago.to_s).not_to be_empty
        end
        expect(profile_views.profile_viewed_by.count).to eq(1)
      end
      it 'finds multiple leads' do
        profile_views.execute(num_times = 50) do |name, time_ago|
          expect(name).not_to be_empty
          expect(time_ago.to_s).not_to be_empty
        end
        expect(profile_views.profile_viewed_by.count).to eq(50)
      end
    end
    context 'when viewers list cannot be found after visiting the page' do
      before do
        allow(session).to receive(:has_selector?).with(viewers_list_css).and_return(false)
      end

      it { expect { profile_views.execute }.to raise_error(ScrapIn::CssNotFound) }
    end
    context 'when viewers list cannot be found after visiting the page' do
      before do
        allow(session).to receive(:has_selector?).with(viewers_list_css).and_return(false)
      end

      it { expect { profile_views.execute }.to raise_error(ScrapIn::CssNotFound) }
    end
  end
end

