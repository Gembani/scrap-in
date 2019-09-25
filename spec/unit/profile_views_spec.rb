require 'spec_helper'

RSpec.describe ScrapIn::ProfileViews do
  include CssSelectors::ProfileViews
  let(:profile_views) { described_class.new(session) }
  let(:session) { instance_double('Capybara::Session') }
  let(:target_page) { Faker::Internet.url }

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

      60.times do |count|
        if count.zero?
          has_selector(session, aggregated_recruiter_css(count + 1), wait: 5)
          has_not_selector(session, public_profile_css(count + 1), wait: 1)
          has_not_selector(session, semi_private_css(count + 1), wait: 1)
          has_not_selector(session, last_element_css(count + 1), wait: 1)
        else
          has_selector(session, public_profile_css(count + 1), wait: 1)
          has_not_selector(session, semi_private_css(count + 1), wait: 1)
          has_not_selector(session, aggregated_recruiter_css(count + 1), wait: 5)
          has_not_selector(session, last_element_css(count + 1), wait: 1)
        end
        profile_item = instance_double(Capybara::Node::Element)

        name_item = instance_double(Capybara::Node::Element)
        allow(name_item).to receive(:text).and_return("name #{count + 1}")
        has_selector(profile_item, name_css)
        find(profile_item, name_item, name_css)

        time_ago_item = instance_double(Capybara::Node::Element)
        allow(time_ago_item).to receive(:text).and_return("time_ago#{count + 1}")
        has_selector(profile_item, time_ago_css)
        find(profile_item, time_ago_item, time_ago_css)

        find(session, profile_item, public_profile_css(count + 1), wait: 1)
      end
    end

    context 'Everything was found (up to 50 profiles)' do
      it 'finds one lead' do
        profile_views.execute(1) do |name, time_ago|
          expect(name).not_to be_empty
          expect(time_ago.to_s).not_to be_empty
        end
        expect(profile_views.profile_viewed_by.count).to eq(1)
      end
      it 'finds multiple leads' do
        profile_views.execute(50) do |name, time_ago|
          expect(name).not_to be_empty
          expect(time_ago.to_s).not_to be_empty
        end
        expect(profile_views.profile_viewed_by.count).to eq(50)
      end
    end
    context 'when viewers list cannot be found after visiting the page' do
      before do
        has_not_selector(session, viewers_list_css)
      end

      it { expect { profile_views.execute }.to raise_error(ScrapIn::CssNotFound) }
    end

    context 'when the name css cannot be found' do
      before do
        profile_item = instance_double(Capybara::Node::Element)
        has_not_selector(profile_item, name_css)
        find(session, profile_item, public_profile_css(2), wait: 1)
      end

      it { expect { profile_views.execute }.to raise_error(ScrapIn::CssNotFound) }
    end

    context 'when the time_ago css cannot be found' do
      before do
        profile_item = instance_double(Capybara::Node::Element)
        name_item = instance_double(Capybara::Node::Element)

        has_selector(profile_item, name_css)
        find(profile_item, name_item, name_css)
        allow(name_item).to receive(:text).and_return("name 1")

        time_ago_item = instance_double(Capybara::Node::Element)
        allow(time_ago_item).to receive(:text).and_return("time_ago1")
        has_not_selector(profile_item, time_ago_css)
        find(profile_item, time_ago_item, time_ago_css)
        find(session, profile_item, public_profile_css(2), wait: 1)
      end

      it { expect { profile_views.execute }.to raise_error(ScrapIn::CssNotFound) }
    end

    context 'when the profile item in neither public, private or last' do
      before do
        has_not_selector(session, public_profile_css(2), wait: 1)
        has_not_selector(session, last_element_css(2), wait: 1)
        has_not_selector(session, semi_private_css(2), wait: 1)
      end

      it { expect { profile_views.execute }.to raise_error(ScrapIn::CssNotFound) }
    end
    context 'when the 30th profile is the last' do
      before do
        has_not_selector(session, public_profile_css(30), wait: 1)
        has_selector(session, last_element_css(30), wait: 1)
      end

      it 'should find only 28 leads (30 - first element - last element)' do
        profile_views.execute(50) do |name, time_ago|
          expect(name).not_to be_empty
          expect(time_ago.to_s).not_to be_empty
        end
        expect(profile_views.profile_viewed_by.count).to eq(28) # the last one does not count as lead
      end
    end
    context 'when the 30th profile is not public but is NOT the last' do
      before do
        has_not_selector(session, public_profile_css(2), wait: 1)
        has_not_selector(session, last_element_css(2), wait: 1)
        has_selector(session, semi_private_css(2), wait: 1)
      end

      it 'should find 40 leads' do
        profile_views.execute(40) do |name, time_ago|
          expect(name).not_to be_empty
          expect(time_ago.to_s).not_to be_empty
        end
        expect(profile_views.profile_viewed_by.count).to eq(40) # the last one does not count as lead
      end
    end
  end
end

