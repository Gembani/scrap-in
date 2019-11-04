require 'spec_helper'

RSpec.describe ScrapIn do
  before(:all) do
    puts 'Capybara is creating a session for all tests...'
    @session = ScrapIn::Session.new(ENV.fetch('username'), ENV.fetch('password'))
  end

  after(:all) do
  
  end
  it 'has a version number_of_invites' do
    expect(ScrapIn::VERSION).not_to be nil
  end

  describe '.sales_nav_scrap_search_list' do
    let(:list_name) { 'Rspec' }
    let(:last_page) { 100 }
    before do
      
    
      @sales_nav_scrap_search_list = @session.sales_nav_scrap_search_list(list_name)
    end

    it 'gets lead from 10 firsts pages' do
      page = 1
      max_page = 10
      until page == max_page
        found_links = []
        next_page_to_process = @sales_nav_scrap_search_list.execute(page) do |link, _image|
          expect(link).to start_with('https://www.linkedin.com/sales/people')
          found_links << link
        end
        expect(found_links.size).to be >= 20
        expect(next_page_to_process).to eq(page + 1)
        page += 1
      end
    end

    it 'gets lead from page 1' do
      found_links = []
      next_page_to_process = @sales_nav_scrap_search_list.execute(1) do |link, _image|
        expect(link).to start_with('https://www.linkedin.com/sales/people')
        found_links << link
      end
      expect(found_links.size).to be >= 20
      expect(next_page_to_process).to eq(2)
    end

    it 'gets profile and image links from all leads of the second page of the list and return the next page' do
      next_page_to_process = @sales_nav_scrap_search_list.execute(3) do |link, _image|
        expect(link).to start_with('https://www.linkedin.com/sales/people')
      end
      expect(next_page_to_process).to eq(4)
    end

    it 'gets profile and image links from all leads of the twelfth page of the list and return the next page' do
      next_page_to_process = @sales_nav_scrap_search_list.execute(12) do |link, _image|
        expect(link).to start_with('https://www.linkedin.com/sales/people')
      end
      expect(next_page_to_process).to eq(13)
    end

    it 'gets leads form the last page' do
      found_links = []
      next_page_to_process = @sales_nav_scrap_search_list.execute(last_page) do |link, _image|
        expect(link).to start_with('https://www.linkedin.com/sales/people')
        found_links << link
      end
      expect(found_links.size).to eq(16)
      expect(next_page_to_process).to eq(101)
    end

    it 'tries to go to the 101th page of the list, doesnt find it and return the first page' do
      next_page_to_process = @sales_nav_scrap_search_list.execute(101) do |_link, _image|
      end
      expect(next_page_to_process).to eq(1)
    end
  end

  describe '.sales_nav_scrap_lead' do
    it 'scraps location, phones, emails and website links for a lead' do
      sales_nav_scrap_lead = @session.sales_nav_scrap_lead(sales_nav_url: ENV.fetch('s_scrap_lead_url'))
      data = sales_nav_scrap_lead.to_hash
      expect(data[:sales_nav_url]).not_to be_nil
      expect(data[:name]).not_to be_nil
      expect(data[:location]).not_to be_nil
      expect(data[:links].first).to eq('https://gembani.com')

      expect(data[:emails].count).to be > 0
      expect(data[:phones].count).to be > 0
      expect(data[:links].count).to be > 0
    end
  end

  describe '.sales_nav_invite' do
    before do
      # Let's mock here some method
      # allsales_nav_ow_any_instance_of(Salesnavot::Invite).to receive(:click_and_connect).and_return(true)
      # allow_any_instance_of(Salesnavot::Invite).to receive(:lead_invited?).and_return(true)
      # allow_any_instance_of(Salesnavot::Invite).to receive(:pending_after_invite?).and_return(true)
    end
    it 'sends invite and send a message' do ## Integration
      # message = 'Hello there'
      # url = 'https://www.linkedin.com/sales/people/ACwAABOC43QB_33UK_zSdjpGT874CI8sI8O2g-Y,NAME_SEARCH,WIxj?_ntb=VRQIgoLqSS%2BxwUkvus4PVA%3D%3D'
      sales_nav_invite = @session.sales_nav_invite(ENV.fetch('s_invite_url'), ENV.fetch('s_invite_message'))
      value = sales_nav_invite.execute
      expect(value).to be true
      puts 'Invite sent !'
    end

    it 'sends invite and send a message when already friends' do ## Integration
      # message = 'Hello there'
      # url = 'https://www.linkedin.com/sales/people/ACwAABI1H9EBeHSOuawCiNLkn6VEP1LHzEz420I,NAME_SEARCH,94gX?_ntb=2zSSN%2FB4Q4uh%2BwB9HHTBCA%3D%3D'
      sales_nav_invite = @session.sales_nav_invite(ENV.fetch('s_invite_url_2'), ENV.fetch('s_invite_message_2'))
      value = sales_nav_invite.execute
      expect(value).to be false
      puts 'already friends'
    end
  end

  describe '.sales_nav_send_message' do
    it ' sends a message from sales nav conversation thread to a lead' do
      # seb_sales_thread = 'https://www.linkedin.com/sales/inbox/6572101845743910912'
      send_message = @session.sales_nav_send_message(ENV.fetch('s_send_message_url'),
                                                    'Hi, this is a test message at ' +
                                                        Time.now.strftime('%H:%M:%S').to_s +
                                                        '. Thanks!')
      send_message.execute(true)
    end

    it ' sends a message from profile url' do
      # seb_sales_thread = 'https://www.linkedin.com/sales/people/ACwAAB2tnsMBfAVq-L4xuYiXAzrugszqNs7Sg1o,NAME_SEARCH,6zds'
      send_message = @session.sales_nav_send_message(ENV.fetch('s_send_message_url_2'),
                                                    'Hi, this is a test message at ' +
                                                        Time.now.strftime('%H:%M:%S').to_s +
                                                        '. Thanks!')
      send_message.execute(true)
    end
  end

  describe '.sales_nav_scrap_threads' do
    context 'when scrapping open threads' do
      xit 'wants to scrap 100 threads but there is less open conversations' do
        count = 0
        @session.sales_nav_scrap_threads.execute(100) do |name, thread|
          puts "#{name}, #{thread}"
          count += 1
        end
        expect(count).to be < 100
      end

      it 'scraps 10 threads, does not need to scroll down to load older conversations' do
        count = 0
        @session.sales_nav_scrap_threads.execute(10) do |name, thread|
          puts "#{name}, #{thread}"
          count += 1
        end
        expect(count).to be > 0
      end

      it 'scraps 30 threads, needs to scroll down 1 time to load older conversations' do
        count = 0
        @session.sales_nav_scrap_threads.execute(30) do |name, thread|
          puts "#{name}, #{thread}"
          count += 1
        end
        expect(count).to be > 0
      end
    end
  end

  describe '.sales_nav_send_inmail' do
    before do
      # let's mock some methods in order to not send the inmail
    end
    it 'sends inmail' do
      # url = 'https://www.linkedin.com/sales/people/ACwAABoqzPMBkNjA1A2yhrvf3CmyLD3fQWqTLCg,NAME_SEARCH,Q68x'
      message = 'Hello from Paris. I\'m'
      subject = 'Introduction'
      sales_nav_send_inmail = @session.sales_nav_send_inmail(ENV.fetch('s_send_inmail_url'), subject, message)
      expect(sales_nav_send_inmail.execute).to be true
    end
  end
  
  describe '.sales_nav_scrap_messages' do
    context 'when a lead has an open conversation but does not match the given name param' do
      it 'raises error' do
        count = 0
        scrap_value = 100
        stephane_messages = @session.sales_nav_scrap_messages(ENV.fetch('s_scrap_messages_url'))#('https://www.linkedin.com/sales/inbox/6588308325002158080')
        expect { stephane_messages.execute(scrap_value, 'CEBULA Sébastien') }.to raise_error(ScrapIn::LeadNameMismatch) # REMOVE 'CEBULA Sebastien'
      end
    end

    context 'when a lead as an open conversation' do
      it 'scraps all messages from thread_url if the number of messages < scrap_value' do
        count = 0
        scrap_value = 100
        stephane_messages = @session.sales_nav_scrap_messages(ENV.fetch('s_scrap_messages_url_2'))#('https://www.linkedin.com/sales/inbox/6588308325002158080')
        stephane_messages.execute(scrap_value) do |message, direction|
          if direction == :incoming
            print 'CONTACT ->  '
          else
            print 'YOU ->  '
          end
          puts message
          count += 1
          expect(count).to be < scrap_value
        end
      end

      it 'scraps the scrap_value last messages from thread_url and scroll only for these messages to load' do
        count = 0
        scrap_value = 25
        seb_messages = @session.sales_nav_scrap_messages(ENV.fetch('s_scrap_messages_url_3'))#('https://www.linkedin.com/sales/inbox/6564811480502460416')
        seb_messages.execute(scrap_value) do |message, direction|
          if direction == :incoming
            print 'CONTACT ->  '
          else
            print 'YOU ->  '
          end
          puts message
          count += 1
          expect(count).to eq(scrap_value)
        end
      end

      it 'Scraps correctly the sender\'s name' do
        count = 0
        scrap_value = 25
        messages = @session.sales_nav_scrap_messages(ENV.fetch('s_scrap_messages_url_4'))#('https://www.linkedin.com/sales/inbox/6560550015541043200')
        messages.execute(scrap_value) do |message, direction|
          if direction == :incoming
            print 'CONTACT ->  '
          else
            print 'YOU ->  '
          end
          puts message
          count += 1
          expect(count).to be < scrap_value
        end
      end
    end
  end
end
