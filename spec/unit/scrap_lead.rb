require 'spec_helper'

RSpec.describe Salesnavot::ScrapLead do
  include Tools
  let(:scrap_lead) do
    described_class.new(config, session)
  end

  let(:phones_element) { instance_double('Capybara::Node::Element') }
  let(:session) { instance_double('Capybara::Session') }
  let(:sales_nav_url) { Faker::Internet.url }
  let(:emails) do
    array = []
    9.times do
      array << Faker::Internet.email
    end
    array
  end

  let(:links) do
    array = []
    9.times do
      array << Faker::Internet.url
    end
    array
  end

  let(:phones) do
    array = []
    9.times do
      array << Faker::PhoneNumber.phone_number
    end
    array
  end

  let(:config) do
    {
      sales_nav_url: sales_nav_url,
      emails: emails,
      phones: phones,
      links: links
    }
  end

  let(:target_page) { 'Target.url' }
  let(:name_css) { '.name-css' }
  let(:infos_css) { '.infos-css' }
  let(:degree_css) { '.degree-css' }
  let(:phones_block_css) { '.phones-block-css' }
  let(:links_block_css) { '.links-block-css' }
  let(:emails_block_css) { '.emails-block-css' }

  describe 'Initializer' do
    subject { described_class }
    it { is_expected.to eq Salesnavot::ScrapLead }
  end

  describe 'instance of described class' do
    subject { scrap_lead.instance_variables }
    it { is_expected.to include(:@session) }
    it { is_expected.to include(:@emails) }
    it { is_expected.to include(:@url) }
    it { is_expected.to include(:@linkedin_url) }
    it { is_expected.to include(:@sales_nav_url) }
    it { is_expected.to include(:@links) }
    it { is_expected.to include(:@phones) }
    it { is_expected.to include(:@error) }
  end

  describe '.execute' do
    context 'when the lead was not found' do
      before do
        allow(scrap_lead).to receive(:target_page).and_return(target_page)
        allow(session).to receive(:visit).with(scrap_lead.sales_nav_url)
        allow(scrap_lead).to receive(:name_css).and_return(name_css)
        allow(session).to receive(:has_selector?).with(name_css).and_return(false)
      end

      it 'raises a css error' do
        expect do
          scrap_lead.execute
        end.to raise_error(css_error(name_css))
      end
    end
    context 'when the lead was found' do
      before do
        allow(scrap_lead).to receive(:target_page).and_return(target_page)
        allow(session).to receive(:visit).with(scrap_lead.sales_nav_url)
        allow(scrap_lead).to receive(:find_lead_name)
        allow(scrap_lead).to receive(:find_lead_degree)
      end
      context 'infos button not found' do
        before do
          allow(scrap_lead).to receive(:infos_css).and_return(infos_css)
          allow(session).to receive(:has_selector?).with(infos_css).and_return(false)
        end
        it 'raises a css error' do
          expect do
            scrap_lead.execute
          end.to raise_error(css_error(infos_css))
        end
      end
      context 'infos button was found' do
        before do
          allow(scrap_lead).to receive(:infos_css).and_return(infos_css)
          allow(scrap_lead).to receive(:find_and_click).with(infos_css)
        end
        context 'phones css was not found' do
          before do
            allow(scrap_lead).to receive(:phones_block_css).and_return(phones_block_css)
            allow(session).to receive(:has_selector?).with(phones_block_css, wait: 1).and_return(false)
          end
          it 'raises a css error' do
            expect do
              scrap_lead.execute
            end.to raise_error(css_error(phones_block_css))
          end

        end
        context 'links css was not found' do
          before do
            allow(scrap_lead).to receive(:scrap_phones)
            allow(scrap_lead).to receive(:links_block_css).and_return(links_block_css)
            allow(session).to receive(:has_selector?).with(links_block_css, wait: 1).and_return(false)
          end
          it 'raises a css error' do
            expect do
              scrap_lead.execute
            end.to raise_error(css_error(links_block_css))
          end

        end
        context 'emails css was not found' do
          before do
            allow(scrap_lead).to receive(:scrap_phones)
            allow(scrap_lead).to receive(:scrap_links)
            allow(scrap_lead).to receive(:emails_block_css).and_return(emails_block_css)
            allow(session).to receive(:has_selector?).with(emails_block_css, wait: 1).and_return(false)
          end
          it 'raises a css error' do
            expect do
              scrap_lead.execute
            end.to raise_error(css_error(emails_block_css))
          end

        end
      end
    end
  end
end
