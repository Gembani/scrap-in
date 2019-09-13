require 'spec_helper'

RSpec.describe ScrapIn::ProfileViews do
  include ScrapIn::Tools
  let(:profile_views) do
    described_class.new(session)
  end

  let(:session) { instance_double('Capybara::Session') }

  let(:target_page) { Faker::Internet.url }
  let(:viewers_list_css) { Faker::Internet.slug }
  let(:profile_view_css) { Faker::Internet.slug }
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
    context 'Viewers list was found' do
      before do
        allow(profile_views).to receive(:visit_target_page)
        50.times do |i|
          allow(profile_views).to receive(:profile_view_css).and_return(profile_view_css)
          allow(session).to receive(:has_selector?).with(profile_view_css, wait: 1).and_return(true)
          allow(profile_views).to receive(:find_name_and_time_ago).with(i + 1).and_yield(
            Faker::Name.name,
            Faker::Time.backward(14, :evening)
          )
        end
      end

      it 'finds one lead' do
        profile_views.execute(num_times = 1) do |name, time_ago|
          expect(name).not_to be_empty
          expect(time_ago.to_s).not_to be_empty
        end
      end
      it 'finds multiple leads' do
        count = 0
        profile_views.execute do |name, time_ago|
          expect(name).not_to be_empty
          expect(time_ago.to_s).not_to be_empty
          count += 1
        end
        expect(count).to eq(50)
      end
    end
    context 'Viewers list was not found on target page' do
      before do
        allow(profile_views).to receive(:target_page).and_return(target_page)
        allow(profile_views).to receive(:viewers_list_css).and_return(viewers_list_css)
        allow(session).to receive(:visit).with(target_page)
        allow(session).to receive(:has_selector?).with(viewers_list_css).and_return(false)
      end

      it 'stops the research and raise error' do
        expect do
          profile_views.execute
        end.to raise_error(ScrapIn::CssNotFound)
      end
    end
  end
end
