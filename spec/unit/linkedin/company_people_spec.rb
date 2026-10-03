require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::CompanyPeople do
  let(:session) { instance_double('Capybara::Session') }
  let(:search) { instance_double('ScrapIn::LinkedIn::SearchPeople') }
  let(:company) { instance_double('ScrapIn::LinkedIn::ScrapCompany', company_url: 'https://www.linkedin.com/company/big-mamma/') }

  before do
    allow(ScrapIn::LinkedIn::ScrapCompany).to receive(:new).and_return(company)
    allow(ScrapIn::LinkedIn::SearchPeople).to receive(:new).and_call_original
  end

  it 'searches the company employees when the page links to them' do
    allow(company).to receive(:company_id).and_return('6964817')
    allow(ScrapIn::LinkedIn::SearchPeople).to receive(:new).with(session, 'chef', current_company: '6964817').and_return(search)
    allow(search).to receive(:execute).with(2).and_yield('https://www.linkedin.com/in/x/', %w[X Chef]).and_return(1)
    results = []
    described_class.new(session, 'https://www.linkedin.com/company/big-mamma/', keywords: 'chef').execute(2) { |*result| results << result }
    expect(results).to eq([['https://www.linkedin.com/in/x/', %w[X Chef]]])
  end

  it 'falls back to the people tab' do
    allow(company).to receive(:company_id).and_return(nil)
    card = instance_double('Capybara::Node::Element', text: "Jacopo Galliano\n3rd+ degree connection\nSous Chef\nMessage")
    profile = instance_double('Capybara::Node::Element')
    allow(profile).to receive(:[]).with(:href).and_return('https://www.linkedin.com/in/jacopo-galliano?miniProfileUrn=x')
    allow(card).to receive(:first).and_return(profile)
    allow(session).to receive(:visit)
    allow(session).to receive(:has_selector?).and_return(true)
    allow(session).to receive(:all).with('main li', wait: 0).and_return([card])
    results = []
    described_class.new(session, 'https://www.linkedin.com/company/big-mamma/', keywords: 'chef').execute { |*result| results << result }
    expect(session).to have_received(:visit).with('https://www.linkedin.com/company/big-mamma/people/?keywords=chef')
    expect(results).to eq([['https://www.linkedin.com/in/jacopo-galliano/', ['Jacopo Galliano', '3rd+ degree connection', 'Sous Chef']]])
  end
end
