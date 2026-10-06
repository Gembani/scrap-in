require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::SearchPeople do
  include CssSelectors::LinkedIn::SearchPeople
  let(:session) { instance_double('Capybara::Session') }
  let(:main) { instance_double('Capybara::Node::Element', 'main') }
  let(:subject) { described_class.new(session, 'gérant restaurant paris') }

  def link(href, text)
    node = instance_double('Capybara::Node::Element', text: text)
    allow(node).to receive(:[]).with(:href).and_return(href)
    node
  end

  # As on live LinkedIn: photo / name / card links per result, and people mentioned inside cards
  let(:page_one) do
    [
      link('https://www.linkedin.com/in/jane-doe?miniProfileUrn=x', ''),
      link('https://www.linkedin.com/in/jane-doe?miniProfileUrn=x', "Jane Doe \n • 2nd\nGérante, Le Petit Cler\nParis\nMessage"),
      link('https://www.linkedin.com/in/jane-doe/', 'Jane Doe'),
      link('http://www.linkedin.com/in/john-roe/', 'John Roe • 3rd+'),
      link('https://www.linkedin.com/in/john-roe/', "John Roe • 3rd+\nChef\nParis"),
      link('https://www.linkedin.com/in/mutual-friend/', 'Mutual Friend'),
    ]
  end

  before do
    allow(session).to receive(:visit)
    allow(session).to receive(:has_selector?).with(profile_link_css, wait: 5).and_return(true)
    has_selector(session, results_container_css)
    allow(session).to receive(:first).with(results_container_css).and_return(main)
    allow(main).to receive(:all).with(profile_link_css, wait: 0).and_return(page_one, [])
  end

  it 'yields each result once, with the lines of its card' do
    results = []
    subject.execute(1) { |url, lines| results << [url, lines] }
    expect(results).to eq([
                            ['https://www.linkedin.com/in/jane-doe/', ['Jane Doe', '2nd', 'Gérante, Le Petit Cler', 'Paris']],
                            ['https://www.linkedin.com/in/john-roe/', ['John Roe', '3rd+', 'Chef', 'Paris']],
                          ])
  end

  it 'searches page by page and stops when a page brings nothing new' do
    expect(subject.execute(3) { nil }).to eq(2)
    expect(session).to have_received(:visit).with(search_url('gérant restaurant paris', 1))
    expect(session).to have_received(:visit).with(search_url('gérant restaurant paris', 2))
    expect(session).not_to have_received(:visit).with(search_url('gérant restaurant paris', 3))
  end

  it 'searches among the employees of a company' do
    described_class.new(session, 'chef', current_company: '6964817').execute(1) { nil }
    expect(session).to have_received(:visit)
      .with('https://www.linkedin.com/search/results/people/?keywords=chef&page=1&currentCompany=%5B%226964817%22%5D')
  end

  it 'searches with the filters of ordinary LinkedIn' do
    described_class.new(session, nil, filters: { title: 'gérant', geo: %w[106383538], industry: [32, 34], network: %w[S],
                                                 profile_language: ['fr'] }).execute(1) { nil }
    expect(session).to have_received(:visit).with(
      'https://www.linkedin.com/search/results/people/?page=1&titleFreeText=g%C3%A9rant&geoUrn=%5B%22106383538%22%5D' \
      '&industry=%5B%2232%22%2C%2234%22%5D&network=%5B%22S%22%5D&profileLanguage=%5B%22fr%22%5D&origin=FACETED_SEARCH'
    )
  end

  it 'refuses a filter LinkedIn does not have' do
    expect { described_class.new(session, 'chef', filters: { seniority: 'senior' }).execute(1) { nil } }.to raise_error(ArgumentError, /seniority/)
  end

  it 'needs keywords or a company' do
    expect { described_class.new(session, ' ') }.to raise_error(ArgumentError)
  end
end
