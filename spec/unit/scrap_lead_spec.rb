require 'spec_helper'


RSpec.shared_examples "a popup closed method" do 
  include CssSelectors::ScrapLead
  context "not on leads page, go to lead page" do 
    before do
      allow(session).to receive(:current_url).with(no_args).and_return("google.com")
      allow(session).to receive(:visit).with(sales_nav_url).and_return(true)
      has_selector(:xpath, close_popup_css)          
      run
    end
    it {
      expect(session).to have_received(:visit).with(sales_nav_url)
    }
  end

  context "on leads page popup closed" do 
    let(:close_button) { instance_double('Capybara::Node::Element') }
    before do
      allow(session).to receive(:current_url).with(no_args).and_return(sales_nav_url)
      allow(session).to receive(:visit).with(sales_nav_url).and_return(true)
      has_selector(:xpath, close_popup_css)          
      allow(close_button).to receive(:click)
      subject.instance_variable_set(:@popup_open, true)
      allow(session).to receive(:find).with(:xpath, close_popup_css).and_return(close_button)
      run
    end
    it {
      expect(session).not_to have_received(:visit).with(sales_nav_url)
    }
    it {
      expect(close_button).to have_received(:click).with(no_args)
    }
  end    
end


RSpec.describe ScrapIn::ScrapLead do
  include Tools
  let(:sales_nav_url) { 'linkedin.com/sales/people/adsahsdfasd' }
  let(:session) { instance_double('Capybara::Session') }
  let(:subject) do
    described_class.new(config, session)
  end
  describe '.name' do
    
    let(:name_div) { instance_double('Capybara::Node::Element') }
    context "out of networks" do 
      it_behaves_like "a popup closed method" do
        before do
          has_selector(name_css) 
          allow(name_div).to receive(:text).with(no_args).and_return("LinkedIn asdfa")
          allow(session).to receive(:find).with(name_css).and_return(name_div)
        end
        let(:run) do
          expect{ subject.name }.to raise_error(OutOfNetworkError)
        end
      end

      it_behaves_like "a popup closed method" do
        let(:name) { "Nicholas Jamnes Stock" }
        before do
          has_selector(name_css) 
          allow(name_div).to receive(:text).with(no_args).and_return(name)
          allow(session).to receive(:find).with(name_css).and_return(name_div)
        end
        let(:run) do
          expect(subject.name).to eq(name)
        end
      end
    end
    
    
    
  end
  let(:phones_element) { instance_double('Capybara::Node::Element') }
  let(:emails) do
    array = []
    9.times do
      array << Faker::Internet.email
    end
    array
  end

  let(:links) do
    array = []
    9.times do
      array << Faker::Internet.url
    end
    array
  end

  let(:phones) do
    array = []
    9.times do
      array << Faker::PhoneNumber.phone_number
    end
    array
  end

  let(:config) do
    {
      sales_nav_url: sales_nav_url,
      emails: emails,
      phones: phones,
      links: links
    }
  end
  
    

end
