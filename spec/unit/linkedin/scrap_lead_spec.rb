require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::ScrapLead do
  include ScrapIn::Tools
  include CssSelectors::LinkedIn::ScrapLead
  let(:session) { instance_double('Capybara::Session') }
  let(:linkedin_url) { 'https://www.linkedin.com/in/toto/' }
  let(:subject) do
    described_class.new(config, session)
  end

  let(:name_node) { instance_double('Capybara::Node::Element') }
  let(:name) { 'Lead\'s name' }
  let(:location_node) { instance_double('Capybara::Node::Element') }
  let(:location) { 'Here' }
  let(:degree_node) { instance_double('Capybara::Node::Element') }
  let(:first_degree?) { '1st' }
  let(:links_array) { [] }
  let(:links) do
    9.times.collect do
      Faker::Internet.url
    end
  end
  let(:phones) { instance_double('Capybara::Node::Element') }
  let(:phone_number) { Faker::PhoneNumber.phone_number }
  let(:emails) { instance_double('Capybara::Node::Element') }
  let(:email) { Faker::Internet.email }

  before do
    find(session, name_css, wait: 5, name_node)
    find(session, location_css, wait: 5, location_node)
    find(session, degree_css, wait: 5, degree_node)
    find(session, emails_css, wait: 5, emails_node)
    find(session, phones_css, wait: 5, phones_node)
    has_selector(session, websites_css, wait: 5)
    allow(session).to receive(:all).with(websites_css, wait: 5).and_return(links_array)
    create_node_array(links_array, 9, "links")

    links_array.each_with_index do |link|
      allow(link).to receive(:text).and_return(links[index])
    end
  end
end