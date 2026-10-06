require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::GeoLookup do
  let(:session) { instance_double('Capybara::Session') }
  let(:body) { instance_double('Capybara::Node::Element') }

  before do
    allow(session).to receive(:visit)
    allow(session).to receive(:find).with('body').and_return(body)
  end

  it "reads LinkedIn's place autocomplete" do
    allow(body).to receive(:text).and_return('[{"id":"106383538","type":"GEO","displayName":"Paris, Île-de-France, France"},' \
                                             '{"id":"x","displayName":"broken"}]')
    expect(described_class.new(session, 'Paris').execute).to eq([{ id: '106383538', name: 'Paris, Île-de-France, France' }])
    expect(session).to have_received(:visit).with(a_string_including('typeaheadType=GEO', 'query=Paris'))
  end

  it 'finds nothing when LinkedIn answers with a page instead' do
    allow(body).to receive(:text).and_return('Sign in to LinkedIn')
    expect(described_class.new(session, 'Paris').execute).to eq([])
  end
end
