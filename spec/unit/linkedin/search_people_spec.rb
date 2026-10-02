require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::SearchPeople do
  include CssSelectors::LinkedIn::SearchPeople
  let(:session) { instance_double('Capybara::Session') }
  let(:main) { instance_double('Capybara::Node::Element', 'main') }
  let(:subject) { described_class.new(session, 'gérant restaurant paris') }

  def link(href, card_text)
    card = instance_double('Capybara::Node::Element', text: card_text)
    node = instance_double('Capybara::Node::Element', text: card_text.lines.first.strip)
    allow(node).to receive(:[]).with(:href).and_return(href)
    allow(node).to receive(:ancestor).with('li').and_return(card)
    node
  end

  let(:page_one) do
    [
      link('https://www.linkedin.com/in/jane-doe?miniProfileUrn=x', "Jane Doe\n2nd\nGérante, Le Petit Cler\nParis"),
      link('https://www.linkedin.com/in/jane-doe/', "Jane Doe\n2nd\nGérante, Le Petit Cler\nParis"),
      link('https://www.linkedin.com/in/john-roe/', "John Roe\n3rd+\nChef\nParis"),
    ]
  end

  before do
    allow(session).to receive(:visit)
    allow(session).to receive(:has_selector?).with(profile_link_css, wait: 5).and_return(true)
    has_selector(session, results_container_css)
    allow(session).to receive(:first).with(results_container_css).and_return(main)
    allow(main).to receive(:all).with(profile_link_css, wait: 0).and_return(page_one, [])
  end

  it 'yields one result per profile with its card lines' do
    results = []
    subject.execute(1) { |url, lines| results << [url, lines] }
    expect(results).to eq([
                            ['https://www.linkedin.com/in/jane-doe/', ['Jane Doe', '2nd', 'Gérante, Le Petit Cler', 'Paris']],
                            ['https://www.linkedin.com/in/john-roe/', ['John Roe', '3rd+', 'Chef', 'Paris']],
                          ])
  end

  it 'searches the keywords page by page and stops when a page brings nothing new' do
    count = subject.execute(3) { nil }
    expect(count).to eq(2)
    expect(session).to have_received(:visit).with(search_url('gérant restaurant paris', 1))
    expect(session).to have_received(:visit).with(search_url('gérant restaurant paris', 2))
    expect(session).not_to have_received(:visit).with(search_url('gérant restaurant paris', 3))
  end

  it 'needs keywords' do
    expect { described_class.new(session, ' ') }.to raise_error(ArgumentError)
  end
end
