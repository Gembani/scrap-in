require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapLead do
  include ScrapIn::Tools
  include CssSelectors::LinkedIn::ScrapLead
  let(:session) { instance_double('Capybara::Session') }
  let(:linkedin_url) { 'https://www.linkedin.com/in/lead_profile/' }
  let(:info_url) { linkedin_url + 'detail/contact-info/' }
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
  let(:degree) { '1st' }
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
    allow(location_node).to receive(:text).and_return(location)

    has_selector(session, degree_css, wait: 5)
    find(session, degree_node, degree_css, wait: 5)
    allow(degree_node).to receive(:text).and_return(degree)

    has_selector(session, emails_css, wait: 5)
    find(session, emails, emails_css, wait: 5)
    allow(emails).to receive(:text).and_return(email)

    has_selector(session, phone_css, wait: 5)
    allow(session).to receive(:first).with(phone_css, wait: 5).and_return(phones_node)
    allow(phones_node).to receive(:text).and_return(phone_number)

    has_selector(session, websites_css, wait: 5)
    allow(session).to receive(:all).with(websites_css, wait: 5).and_return(links_array)
    create_node_array(links_array, 9, 'links')
    links_array.each_with_index do |link, index|
      allow(link).to receive(:text).and_return(links[index])
    end
  end

  context 'when the linkedin_url is not a right url' do
    before do
      config[:linkedin_url] = 'Not a linkedin url'
    end
    it 'raises an error' do
      expect { subject }.to raise_error('Lead\'s linkedin url is not valid')
    end
  end

  context 'when the linkedin_url is empty' do
    let(:config) { {} }
    it 'raises an error' do
      expect { subject }.to raise_error('Lead\'s linkedin url is not valid')
    end
  end

  context 'when the informations need to be scraped on the lead\'s page' do
    context 'when on the lead\'s info page' do
      before do
        allow(session).to receive(:current_url).and_return(info_url)
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
        subject.name
      end
      it 'does not visit new page' do
        expect(session).not_to receive(:visit)
      end

      context 'when no name_css' do
        before { has_not_selector(session, name_css, wait: 5) }
        it { expect { subject.name }.to raise_error(/#{name_css}/) }
        it { expect { subject.name }.to raise_error(ScrapIn::CssNotFound) }
      end

      context 'when want the name' do
        it { expect(subject.name).to eq(name) }
      end

      context 'when no location_css' do
        before { has_not_selector(session, location_css, wait: 5) }
        it { expect { subject.location }.to raise_error(/#{location_css}/) }
        it { expect { subject.location }.to raise_error(ScrapIn::CssNotFound) }
      end

      context 'when want the location' do
        it { expect(subject.location).to eq(location) }
      end

      context 'when no degree_css' do
        before { has_not_selector(session, degree_css, wait: 5) }
        it { expect { subject.first_degree? }.to raise_error(/#{degree_css}/) }
        it { expect { subject.first_degree? }.to raise_error(ScrapIn::CssNotFound) }
      end

      context 'when want the degree' do
        it { expect(subject.first_degree?).to eq(degree) }
      end
    end
  end

  context 'when the informations need to be scraped on the lead\'s info page' do
    context 'when on the lead\'s page' do
      before do
        allow(session).to receive(:current_url).and_return(linkedin_url)
        allow(session).to receive(:visit).with(info_url).and_return(true)
        subject.scrap_emails
      end
      it 'visits info page' do
        expect(session).to have_received(:visit).with(info_url)
      end
    end

    context 'when on the lead\'s info page' do
      before do
        allow(session).to receive(:current_url).and_return(info_url)
        subject.instance_variable_set(:@popup_open, true)
        subject.scrap_emails
      end
      it 'does not visit lead\'s page' do
        expect(session).not_to receive(:visit)
      end

      context 'when no emails_css' do
        before { has_not_selector(session, emails_css, wait: 5) }
        it { expect(subject.scrap_emails).to eq([]) }
      end

      context 'when want the emails' do
        it { expect(subject.scrap_emails).to eq([email]) }
      end

      context 'when no phone_css' do
        before { has_not_selector(session, phone_css, wait: 5) }
        it { expect(subject.scrap_phones).to eq([]) }
      end

      context 'when want the phones' do
        it { expect(subject.scrap_phones).to eq([phone_number]) }
      end

      context 'when no websites_css' do
        before { has_not_selector(session, websites_css, wait: 5) }
        it { expect(subject.scrap_links).to eq([]) }
      end

      context 'when want the websites' do
        it { expect(subject.scrap_links).to eq(links) }
      end
    end
  end

  describe '.scrap_datas' do
    before do
      allow(subject).to receive(:scrap_phones).and_return([phone_number])
      allow(subject).to receive(:scrap_links).and_return([links])
      allow(subject).to receive(:scrap_emails).and_return([email])
    end

    it {
      expect(subject.scrap_datas).to eq(
        phones: [phone_number],
        links: [links],
        emails: [email]
      )
    }
  end

  describe '.to_hash' do
    let(:scrap_datas) { { scrap: 'datas' } }
    before do
      allow(subject).to receive(:name).and_return(name)
      allow(subject).to receive(:location).and_return(location)
      allow(subject).to receive(:first_degree?).and_return(degree)
      allow(subject).to receive(:scrap_datas).and_return(scrap_datas)
    end

    it {
      expect(subject.to_hash).to eq(
        linkedin_url: linkedin_url,
        name: name,
        location: location,
        first_degree: degree,
        scrap: 'datas'
      )
    }
  end
end
