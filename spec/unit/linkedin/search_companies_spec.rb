require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::SearchCompanies do
  let(:session) { instance_double('Capybara::Session') }
  let(:main) { instance_double('Capybara::Node::Element', 'main') }
  let(:subject) { described_class.new(session, 'Maison Edgar') }

  def link(href, text)
    node = instance_double('Capybara::Node::Element', text: text)
    allow(node).to receive(:[]).with(:href).and_return(href)
    node
  end

  before do
    allow(session).to receive(:visit)
    allow(session).to receive(:has_selector?).and_return(true)
    allow(session).to receive(:first).with('main').and_return(main)
    allow(main).to receive(:all).and_return([
                                             link('https://www.linkedin.com/company/maison-edgar/', "Maison Edgar\nParis\nFollow\n6 followers"),
                                             link('https://www.linkedin.com/company/maison-edgar/', 'Maison Edgar'),
                                             link('https://www.linkedin.com/company/maison-edgar-paris/posts/', "Maison Edgar Paris\nReal Estate\n9 followers"),
                                           ], [])
  end

  it 'yields company pages with their cards' do
    results = []
    subject.execute(1) { |url, lines| results << [url, lines] }
    expect(results).to eq([
                            ['https://www.linkedin.com/company/maison-edgar/', ['Maison Edgar', 'Paris', '6 followers']],
                            ['https://www.linkedin.com/company/maison-edgar-paris/', ['Maison Edgar Paris', 'Real Estate', '9 followers']],
                          ])
    expect(session).to have_received(:visit).with('https://www.linkedin.com/search/results/companies/?keywords=Maison+Edgar&page=1')
  end
end
