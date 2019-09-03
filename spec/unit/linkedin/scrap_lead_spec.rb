require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapLead do
  include ScrapIn::Tools
  let(:session) { instance_double('Capybara::Session') }
  let(:linkedin_url) { 'https://www.linkedin.com/in/toto/' }
end