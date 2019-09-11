require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::SendMessage do
  include CssSelectors::LinkedIn::SendMessage
  
  let(:session) { instance_double('Capybara::Session') }
end