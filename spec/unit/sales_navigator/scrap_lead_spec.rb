require 'spec_helper'

RSpec.shared_examples "a popup closed method" do 
  include CssSelectors::SalesNavigator::ScrapLead
  context "not on leads page, go to lead page" do 
    before do
      allow(session).to receive(:current_url).with(no_args).and_return("google.com")
      allow(session).to receive(:visit).with(sales_nav_url).and_return(true)
      has_selector(session, :xpath, close_popup_css)          
      run
    end
    it {
      expect(session).to have_received(:visit).with(sales_nav_url)
    }
  end

  context "on leads page popup opened" do 
    let(:close_button) { instance_double('Capybara::Node::Element') }
    before do
      allow(session).to receive(:current_url).with(no_args).and_return(sales_nav_url)
      allow(session).to receive(:visit).with(sales_nav_url).and_return(true)
      has_selector(session, :xpath, close_popup_css)          
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

RSpec.shared_examples "a popup open method" do 
  include CssSelectors::SalesNavigator::ScrapLead
  let(:more_info_button) {instance_double('Capybara::Node::Element') }
  context "not on leads page, go to lead page, open popup" do 
    before do
      allow(session).to receive(:current_url).with(no_args).and_return("google.com")
      allow(session).to receive(:visit).with(sales_nav_url).and_return(true)
      has_selector(session, infos_css)          
      allow(more_info_button).to receive(:click)
      allow(session).to receive(:find).with(infos_css).and_return(more_info_button)
      run
    end
    it {
      expect(session).to have_received(:visit).with(sales_nav_url)
    }
    it {
      expect(more_info_button).to have_received(:click).with(no_args)
    }
  end

  context "on leads page, popup opened is already in correct state" do 
    before do
      allow(session).to receive(:current_url).with(no_args).and_return(sales_nav_url)
      allow(session).to receive(:visit).with(sales_nav_url).and_return(true)
      subject.instance_variable_set(:@popup_open, true)
      has_selector(session, infos_css)          
      allow(more_info_button).to receive(:click)
      allow(session).to receive(:find).with(:xpath, infos_css).and_return(more_info_button)
      run
    end
    it {
      expect(session).not_to have_received(:visit).with(sales_nav_url)
    }
    it {
      expect(more_info_button).not_to have_received(:click).with(no_args)
    }
  end 
end

RSpec.describe ScrapIn::SalesNavigator::ScrapLead do
  include ScrapIn::Tools
  let(:session) { instance_double('Capybara::Session') }
  let(:sales_nav_url) { 'linkedin.com/sales/people/adsahsdfasd' }
  let(:config) do
    {
      sales_nav_url: sales_nav_url
    }
  end
  let(:subject) do
    described_class.new(config, session)
  end

  describe '.name' do
    let(:name_div) { instance_double('Capybara::Node::Element') }
    context "out of network" do 
      it_behaves_like "a popup closed method" do
        before do
          has_selector(session, name_css) 
          allow(name_div).to receive(:text).with(no_args).and_return("LinkedIn Member")
          allow(session).to receive(:find).with(name_css).and_return(name_div)
        end
        let(:run) do
          expect{ subject.name }.to raise_error(ScrapIn::OutOfNetworkError)
        end
      end
      context "css not found" do 
        it_behaves_like "a popup closed method" do
          before do
            has_not_selector(session, name_css) 
           end
          let(:run) do
            
            expect{ subject.name }.to raise_error(ScrapIn::CssNotFound)
          end
        end
      end

      context "in network" do
        it_behaves_like "a popup closed method" do
          let(:name) { "Nicholas Jamnes Stock" }
          before do
            has_selector(session, name_css) 
            allow(name_div).to receive(:text).with(no_args).and_return(name)
            allow(session).to receive(:find).with(name_css).and_return(name_div)
          end
          let(:run) do
            expect(subject.name).to eq(name)
          end
        end
      end
    end
  end

  describe '.location' do
    context "location css not found" do 
      it_behaves_like "a popup closed method" do
        before do
          has_not_selector(session, location_css)
        end
        let(:run) do
          expect{ subject.location }.to raise_error(ScrapIn::CssNotFound)
        end
      end
    end
    context "location css found" do 
      it_behaves_like "a popup closed method" do
        let(:location) { "location_payload" }
        let(:location_node) { instance_double('Capybara::Node::Element') }
        
        before do
          has_selector(session, location_css)
          allow(location_node).to receive(:text).and_return(location)
          allow(session).to receive(:find).with(location_css).and_return(location_node)
        end
        let(:run) do
          expect(subject.location).to eq(location)
        end
      end
    end
  end

  describe '.first_degree?' do
    context "first degree css not found" do
      it_behaves_like "a popup closed method" do
        before do
          has_not_selector(session, degree_css, wait: 1)
        end
        let(:run) do
          expect{ subject.first_degree? }.to raise_error(ScrapIn::CssNotFound)
        end
      end
    end
    context "first degree css 1rst" do
      it_behaves_like "a popup closed method" do
        let(:degree_node) { instance_double('Capybara::Node::Element')}
        before do
          has_selector(session, degree_css, wait: 1)
          allow(degree_node).to receive(:text).with(no_args).and_return("1st")
          allow(session).to receive(:find).with(degree_css).and_return(degree_node)
        end
        let(:run) do
          expect(subject.first_degree?).to eq(true)
        end
      end
    end
    
    context "first degree css not first" do
      it_behaves_like "a popup closed method" do
        let(:degree_node) { instance_double('Capybara::Node::Element')}
        before do
          has_selector(session, degree_css, wait: 1)
          allow(degree_node).to receive(:text).with(no_args).and_return("2nd")
          allow(session).to receive(:find).with(degree_css).and_return(degree_node)
        end
        let(:run) do
          expect(subject.first_degree?).to eq(false)
        end
      end
    end
  end
  describe '.scrap_phones' do
    context "does not have block selector" do 
      it_behaves_like "a popup open method" do
        before do
          has_not_selector(session, phones_block_css, wait: 1)
        end
        let(:run) do 
          expect(subject.scrap_phones).to eq([])
        end
      end
    end
    context "has email nodes" do
      let(:phones) do
        9.times.collect do
          Faker::PhoneNumber.phone_number
        end
      end
     
      let(:phone_nodes) do
        9.times.collect do |key|
          phone_node = instance_double('Capybara::Node::Element')
          allow(phone_node).to receive(:text).with(no_args).and_return(phones[key])
          phone_block_node = instance_double('Capybara::Node::Element')
          allow(phone_block_node).to receive(:find).with(phone_css).and_return(phone_node)
          phone_block_node
        end
      end
    
      it_behaves_like "a popup open method" do
        before do
          has_selector(session, phones_block_css, wait: 1)
          allow(session).to receive(:all).with(phones_block_css).and_return(phone_nodes)
        end
        let(:run) do
          expect(subject.scrap_phones).to eq(phones)
        end
      end
    end
  end
  describe '.scrap_emails' do
    context "does not have block selector" do 
      it_behaves_like "a popup open method" do
        before do
          has_not_selector(session, emails_block_css, wait: 1)
        end
        let(:run) do 
          expect(subject.scrap_emails).to eq([])
        end
      end
    end
    context "has email nodes" do
      let(:emails) do
        9.times.collect do
          Faker::Internet.email
        end
      end
     
      let(:email_nodes) do
        9.times.collect do |key|
          email_node = instance_double('Capybara::Node::Element')
          allow(email_node).to receive(:text).with(no_args).and_return(emails[key])
          email_block_node = instance_double('Capybara::Node::Element')
          allow(email_block_node).to receive(:find).with(email_css).and_return(email_node)
          email_block_node
        end
      end
    
      it_behaves_like "a popup open method" do
        before do
          has_selector(session, emails_block_css, wait: 1)
          allow(session).to receive(:all).with(emails_block_css).and_return(email_nodes)
        end
        let(:run) do
          expect(subject.scrap_emails).to eq(emails)
        end
      end
    end
  end

  describe '.scrap_links' do
    context "does not have block selector" do 
      it_behaves_like "a popup open method" do
        before do
          has_not_selector(session, links_block_css, wait: 1)
        end
        let(:run) do 
          expect(subject.scrap_links).to eq([])
        end
      end
    end
    context "has link nodes" do
      let(:links) do
        9.times.collect do
          Faker::Internet.url
        end
      end
     
      let(:link_nodes) do
        9.times.collect do |key|
          link_node = instance_double('Capybara::Node::Element')
          allow(link_node).to receive(:text).with(no_args).and_return(links[key])
          link_block_node = instance_double('Capybara::Node::Element')
          allow(link_block_node).to receive(:find).with(link_css).and_return(link_node)
          link_block_node
        end
      end
    
      it_behaves_like "a popup open method" do
        before do
          has_selector(session, links_block_css, wait: 1)
          allow(session).to receive(:all).with(links_block_css).and_return(link_nodes)
        end
        let(:run) do
          expect(subject.scrap_links).to eq(links)
        end
      end
    end
  end

  describe '.scrap_datas' do
    let(:phones) { "phones_payload" }
    let(:links) { "links_payload" }
    let(:emails) { "emails_payload" }
    
    before do
      allow(subject).to receive(:scrap_phones).with(no_args).and_return(phones)
      allow(subject).to receive(:scrap_links).with(no_args).and_return(links)
      allow(subject).to receive(:scrap_emails).with(no_args).and_return(emails)
    end

    it {
      expect(subject.scrap_datas).to eq({
        phones: phones,
        links: links,
        emails: emails
      })
    }
   
  end
  
  describe '.to_hash' do
    let(:name) { "name_payload" }
    let(:location) { "location_payload" }
    let(:first_degree?) { "first_degree_payload" }
    let(:scrap_datas) { {scrap: "data"} }
    
    before do
      allow(subject).to receive(:name).with(no_args).and_return(name)
      allow(subject).to receive(:location).with(no_args).and_return(location)
      allow(subject).to receive(:first_degree?).with(no_args).and_return(first_degree?)
      allow(subject).to receive(:scrap_datas).with(no_args).and_return(scrap_datas)
    end
    
    it {
      expect(subject.to_hash).to eq({sales_nav_url: sales_nav_url, name: name, location: location, first_degree: first_degree?, scrap: "data"})
    }
  end
end
