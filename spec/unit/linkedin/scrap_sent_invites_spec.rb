# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapSentInvites do
  let(:scrap_sent_invites) { described_class.new(session) }
  let(:session) { instance_double('Capybara::Session', 'session') }
  let(:visit_url) { 'https://www.linkedin.com/mynetwork/invitation-manager/sent/' }

  let(:item_node) { instance_double('Capybara::Node::Element', 'item') }
  let(:next_button_node) { instance_double('Capybara::Node::Element', 'next_button') }

  let(:name_string) { Faker::Name.name }
  let(:url_pre_click_1) { Faker::Internet.url }
  let(:url_pre_click_2) { Faker::Internet.url }

  include CssSelectors::LinkedIn::ScrapSentInvites

  before do
    disable_puts
    disable_script

    allow(session).to receive(:visit).with(visit_url)

    has_selector(session, invitation_list_css)

    count = 0
    50.times do
      has_selector(session, nth_lead_css(count, invitation: false), wait: 10)
      has_selector(session, nth_lead_css(count), wait: 3)
      has_selector(session, nth_lead_css(count))

      allow(session).to receive(:find).with(nth_lead_css(count)).and_return(item_node)
      allow(item_node).to receive(:native)
      allow(item_node).to receive(:text).and_return(name_string)
      
      count += 1
    end
  end

  describe '.execute' do
    context 'no selector for nth_lead' do
      before do
        count = 0
        50.times do
          has_not_selector(session, nth_lead_css(count), wait: 3)
          count += 1
        end
      end

      it 'return false' do
        result = scrap_sent_invites.find_lead_name(1) do |name|
          expect(name).to be_empty
          expect(result).to eq(false)
        end
      end
    end

    context 'name is empty' do
      before do
        allow(name_string).to receive(:empty?).and_return(true)
      end

      it 'return false' do
        result = scrap_sent_invites.find_lead_name(1) do |name|
          expect(name).to be_empty
          expect(result).to eq(false)
        end
      end
    end

    context 'init_list doesnt work' do
      before do
        has_not_selector(session, invitation_list_css)
      end

      it 'init list return false' do
        expect(scrap_sent_invites.init_list(visit_url)).to eq(false)
      end

      it 'execute return false' do
        expect(scrap_sent_invites.execute).to eq(false)
      end
    end

    context 'no selector nth_lead_css' do
      context 'the click worked' do
        before do
          count = 0
          50.times do
            has_not_selector(session, nth_lead_css(count, invitation: false), wait: 10)
            allow(session).to receive(:current_url).and_return(url_pre_click_1, url_pre_click_2)
            
            has_selector(session, next_button_css)
            allow(session).to receive(:find).with(next_button_css).and_return(next_button_node)
          end
          allow(next_button_node).to receive(:click).and_return(true)
        end

        it 'next_page return true' do
          expect(scrap_sent_invites.next_page).to eq(true)
        end
      end

      context 'the click did not work' do
        before do
          count = 0
          50.times do
            has_not_selector(session, nth_lead_css(count, invitation: false), wait: 10)
            allow(session).to receive(:current_url).and_return(url_pre_click_1)
            
            has_selector(session, next_button_css)
            allow(session).to receive(:find).with(next_button_css).and_return(next_button_node)
          end
          allow(next_button_node).to receive(:click).and_return(false)
        end

        it 'next_page return false' do
          expect(scrap_sent_invites.next_page).to eq(false)
        end

        it 'execute loop break' do
          expect(scrap_sent_invites.execute).to eq(true)
        end
      end
    end

    context 'no selector for nth lead' do
      before do
        count = 0
        50.times do
          has_not_selector(session, nth_lead_css(count))
        end
      end

      it do
        expect { scrap_sent_invites.execute }
          .to raise_error(ScrapIn::CssNotFound)
      end
    end

    context 'normal behavior' do
      it do
        50.times do
          result = scrap_sent_invites.execute do |name|
            expect(name).not_to be_empty
          end
          expect(result).to eq(true)
        end
      end
    end
  end
end
