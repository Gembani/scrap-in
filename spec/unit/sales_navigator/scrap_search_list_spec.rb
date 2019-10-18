RSpec.describe ScrapIn::SalesNavigator::ScrapSearchList do
  include CssSelectors::SalesNavigator::ScrapSearchList
  include ScrapIn::Tools

  let(:scrap_search_instance) { described_class.new(session, list_identifier) }
  let(:session) { instance_double('Capybara::Session', 'session') }
  let(:list_identifier) { 'My list' }

  
end
