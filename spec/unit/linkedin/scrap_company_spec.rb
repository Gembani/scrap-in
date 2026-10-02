require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapCompany do
  include CssSelectors::LinkedIn::ScrapCompany
  let(:session) { instance_double('Capybara::Session') }
  let(:subject) { described_class.new(session, 'https://www.linkedin.com/company/le-petit-cler/posts/?x=1') }

  def text_node(text)
    instance_double('Capybara::Node::Element', text: text)
  end

  before do
    allow(session).to receive(:visit)
    has_selector(session, company_name_css, wait: 10)
    find(session, text_node(' Le Petit Cler '), company_name_css, wait: 10)
    allow(session).to receive(:first).and_return(nil)
    {
      'Website' => 'https://lepetitcler.fr', 'Industry' => 'Restaurants', 'Company size' => '11-50 employees',
    }.each do |label, value|
      allow(session).to receive(:first).with(:xpath, about_value_xpath(label), minimum: 0, wait: 1).and_return(text_node(value))
    end
  end

  it 'reads the about page' do
    expect(subject.to_hash).to eq(
      name: 'Le Petit Cler', linkedin_company_url: 'https://www.linkedin.com/company/le-petit-cler/',
      website: 'https://lepetitcler.fr', industry: 'Restaurants', company_size: '11-50 employees',
      headquarters: nil, overview: nil
    )
    expect(session).to have_received(:visit).with('https://www.linkedin.com/company/le-petit-cler/about/')
  end

  it 'refuses other urls' do
    expect { described_class.new(session, 'https://www.linkedin.com/in/jane/') }.to raise_error(ArgumentError)
  end
end
