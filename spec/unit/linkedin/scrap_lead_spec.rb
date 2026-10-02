require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapLead do
  include CssSelectors::LinkedIn::ScrapLead
  let(:session) { instance_double('Capybara::Session') }
  let(:linkedin_url) { 'https://www.linkedin.com/in/lead_profile/' }
  let(:info_url) { linkedin_url + 'overlay/contact-info/' }
  let(:config) { { linkedin_url: linkedin_url } }
  let(:subject) { described_class.new(config, session) }

  let(:name) { 'Lead\'s name' }
  let(:location) { 'Greater Paris Metropolitan Region' }
  let(:top_card_texts) { ['· 1st', 'Founder | Tech Entrepreneur', location, '·', 'Contact info', 'Strevoo'] }
  let(:top_card) { instance_double('Capybara::Node::Element', 'top_card') }
  let(:name_node) { instance_double('Capybara::Node::Element', 'name_node', text: name) }
  let(:dialog) { instance_double('Capybara::Node::Element', 'dialog') }

  let(:email) { Faker::Internet.email }
  let(:phone_number) { Faker::PhoneNumber.phone_number }
  let(:links) { ['ragit.me', 'example.com'] }

  def nodes(texts)
    texts.map { |text| instance_double('Capybara::Node::Element', text: text) }
  end

  def contact_values(label, texts)
    allow(dialog).to receive(:all).with(:xpath, contact_values_xpath(label), wait: 1).and_return(nodes(texts))
  end

  before do
    allow(session).to receive(:current_url).and_return(linkedin_url)
    allow(session).to receive(:visit)

    has_selector(session, top_card_css, wait: 10)
    find(session, top_card, top_card_css, wait: 10)
    has_selector(top_card, name_css, wait: 5)
    find(top_card, name_node, name_css, wait: 5)
    allow(top_card).to receive(:all).with('p') { nodes(top_card_texts) }
    allow(top_card).to receive(:click_link).with(contact_info_text)

    has_selector(session, contact_info_css, wait: 5)
    find(session, dialog, contact_info_css, wait: 5)
    contact_values('Email', [email])
    contact_values('Phone', ["#{phone_number} (Mobile)"])
    contact_values('Website', ['ragit.me (Personal)', 'example.com (Company)'])
  end

  context 'when the linkedin_url is not a right url' do
    before { config[:linkedin_url] = 'Not a linkedin url' }
    it { expect { subject }.to raise_error('Lead\'s linkedin url is not valid') }
  end

  context 'when the linkedin_url is empty' do
    let(:config) { {} }
    it { expect { subject }.to raise_error('Lead\'s linkedin url is not valid') }
  end

  describe 'top card informations' do
    context 'when on another page' do
      before do
        allow(session).to receive(:current_url).and_return('https://www.linkedin.com/feed/')
        subject.name
      end
      it { expect(session).to have_received(:visit).with(linkedin_url) }
    end

    context 'when the contact info popup is open' do
      before do
        allow(session).to receive(:current_url).and_return(info_url)
        subject.instance_variable_set(:@popup_open, true)
        subject.name
      end
      it { expect(session).to have_received(:visit).with(linkedin_url) }
    end

    context 'when on the lead\'s page' do
      it 'does not visit a new page' do
        subject.name
        expect(session).not_to have_received(:visit)
      end

      it { expect(subject.name).to eq(name) }
      it { expect(subject.location).to eq(location) }
      it { expect(subject.first_degree?).to eq(true) }

      context 'when there is no top card' do
        before { has_not_selector(session, top_card_css, wait: 10) }
        it { expect { subject.name }.to raise_error(ScrapIn::CssNotFound, /#{Regexp.escape(top_card_css)}/) }
      end

      context 'when there is no location' do
        let(:top_card_texts) { ['· 1st', 'Founder | Tech Entrepreneur', '·', 'Contact info'] }
        it { expect(subject.location).to be_nil }
      end

      context 'when the lead is 2nd degree' do
        let(:top_card_texts) { ['· 2nd', 'Founder', location, '·', 'Contact info'] }
        it { expect(subject.first_degree?).to eq(false) }
      end
    end
  end

  describe 'contact informations' do
    it 'opens the contact info popup only once' do
      subject.scrap_emails
      subject.scrap_phones
      expect(top_card).to have_received(:click_link).with(contact_info_text).once
    end

    it { expect(subject.scrap_emails).to eq([email]) }
    it { expect(subject.scrap_phones).to eq(["#{phone_number} (Mobile)"]) }
    it { expect(subject.scrap_links).to eq(links) }

    context 'when there are no emails' do
      before { contact_values('Email', []) }
      it { expect(subject.scrap_emails).to eq([]) }
    end

    context 'when the contact info popup cannot be found' do
      before { has_not_selector(session, contact_info_css, wait: 5) }
      it { expect { subject.scrap_emails }.to raise_error(ScrapIn::CssNotFound) }
    end
  end

  describe '.to_hash' do
    it do
      expect(subject.to_hash).to eq(
        name: name,
        headline: 'Founder | Tech Entrepreneur',
        current_company: 'Strevoo',
        location: location,
        linkedin_url: linkedin_url,
        first_degree: true,
        phones: ["#{phone_number} (Mobile)"],
        links: links,
        emails: [email]
      )
    end
  end

  describe 'headline and current company' do
    it { expect(subject.headline).to eq('Founder | Tech Entrepreneur') }
    it { expect(subject.current_company).to eq('Strevoo') }

    context 'without a location' do
      let(:top_card_texts) { ['· 2nd', 'Chef', '·', 'Contact info'] }
      it { expect(subject.headline).to eq('Chef') }
      it { expect(subject.location).to be_nil }
      it { expect(subject.current_company).to be_nil }
    end
  end
end
