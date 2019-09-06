require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapLead do
  include ScrapIn::Tools
  include CssSelectors::LinkedIn::ScrapLead
  let(:session) { instance_double('Capybara::Session') }
  let(:linkedin_url) { 'https://www.linkedin.com/in/lead_profile/' }
  let(:config) do
    {
    linkedin_url: linkedin_url
    }
  end
  let(:subject) do
    described_class.new(config, session)
  end

  let(:name_node) { instance_double('Capybara::Node::Element') }
  let(:name) { 'Lead\'s name' }
  let(:location_node) { instance_double('Capybara::Node::Element') }
  let(:location) { 'Here' }
  let(:degree_node) { instance_double('Capybara::Node::Element') }
  let(:first_degree?) { '1st' }
  let(:links_array) { [] }
  let(:links) do
    9.times.collect do
      Faker::Internet.url
    end
  end
  let(:phones_node) { instance_double('Capybara::Node::Element') }
  let(:phone_number) { Faker::PhoneNumber.phone_number }
  let(:emails) { instance_double('Capybara::Node::Element') }
  let(:email) { Faker::Internet.email }

  before do
    has_selector(session, name_css, wait: 5)
    find(session, name_node, name_css, wait: 5)
    allow(name_node).to receive(:text).and_return(name)

    has_selector(session, location_css, wait: 5)
    find(session, location_node, location_css, wait: 5)

    has_selector(session, degree_css, wait: 5)
    find(session, degree_node, degree_css, wait: 5)

    has_selector(session, emails_css, wait: 5)
    find(session, emails, emails_css, wait: 5)
    allow(emails).to receive(:text).and_return(email)

    has_selector(session, phone_css, wait: 5)
    allow(session).to receive(:first).with(phone_css, wait: 5).and_return(phones_node)
    allow(phones_node).to receive(:text).and_return(phone_number)

    has_selector(session, websites_css, wait: 5)
    allow(session).to receive(:all).with(websites_css, wait: 5).and_return(links_array)
    create_node_array(links_array, 9, "links")
    links_array.each_with_index do |link, index|
      allow(link).to receive(:text).and_return(links[index])
    end
  end

  context 'when the linkedin_url is not a right url' do
    before { linkedin_url = 'Not a linkedin url' }
    it 'raises an error' do
      expect { raise StandardError, 'Lead\'s linkedin url is not valid' }.to raise_error('Lead\'s linkedin url is not valid')
    end
  end

  context 'when the informations need to be scraped on the profile lead\'s page' do
    context 'when not on the lead\'s page' do
      before do
        allow(session).to receive(:current_url).and_return("google.com")
        allow(session).to receive(:visit).with(linkedin_url).and_return(true)
        subject.instance_variable_set(:@popup_open, true)
        subject.name
      end
      it 'goes to lead\'s page' do
        expect(session).to have_received(:visit).with(linkedin_url)
      end
    end

    context 'when on the lead\'s page' do
      before do
        allow(session).to receive(:current_url).and_return(linkedin_url)
        subject.instance_variable_set(:@popup_open, false)
        subject.name
      end
      it 'does not visit new page' do
        expect(session).not_to receive(:visit)
      end
    end
    context 'when no name_css' do
      before do
        allow(session).to receive(:current_url).and_return(linkedin_url)
        subject.instance_variable_set(:@popup_open, false)
        has_not_selector(session, name_css, wait: 5)
      end
      it { expect(session.name).to raise_error(/#{name_css}/) }
      it { expect(session.name).to raise_error(ScrapIn::CssNotFound) }
    end
  end
end

# subject.instance_variable_set(:@popup_open, true)