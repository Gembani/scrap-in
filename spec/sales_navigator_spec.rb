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
    let(:list_url) { ENV.fetch('s_scrap_search_list') }
    let(:last_page) { 20 }
    before do
      @sales_nav_scrap_search_list = @session.sales_nav_scrap_search_list(list_url)
    end

    it 'gets lead from 10 firsts pages' do
      page = 1
      max_page = 10
      until page > max_page
        found_links = []
        puts "page #{page}"
        next_page_to_process = @sales_nav_scrap_search_list.execute(page) do |link, name|
          expect(link).to start_with('https://www.linkedin.com/sales/people')
          puts "#{name}"
          found_links << link
        end
        expect(found_links.size).to be > 20
        expect(next_page_to_process).to eq(page + 1)
        page += 1
      end
    end
  
    it 'gets leads from the last page' do
      found_links = []
      next_page_to_process = @sales_nav_scrap_search_list.execute(last_page) do |link, _image|
        expect(link).to start_with('https://www.linkedin.com/sales/people')
        found_links << link
      end
      expect(found_links.size).to eq(25)
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
    it 'sends invite and send a message' do ## Integration
      sales_nav_invite = @session.sales_nav_invite(ENV.fetch('s_invite_url'), ENV.fetch('s_invite_message'), false)
      value = sales_nav_invite.execute
      expect(value).to be true
      puts 'Invite sent !'
    end

    it 'sends invite and send a message when already friends' do ## Integration
      sales_nav_invite = @session.sales_nav_invite(ENV.fetch('s_invite_url_2'), ENV.fetch('s_invite_message_2'), false)
      value = sales_nav_invite.execute
      expect(value).to be false
    end
  end

  describe '.sales_nav_send_message' do
    it ' sends a message from sales nav conversation thread to a lead' do
      send_message = @session.sales_nav_send_message(ENV.fetch('s_send_message_url'),
                                                     'Hi, this is a test message at ' +
                                                         Time.now.strftime('%H:%M:%S').to_s +
                                                         '. Thanks!')
      send_message.execute(true)
    end

    it ' sends a message from profile url' do
      send_message = @session.sales_nav_send_message(ENV.fetch('s_send_message_url_2'),
                                                     'Hi, this is a test message at ' +
                                                         Time.now.strftime('%H:%M:%S').to_s +
                                                         '. Thanks!')
      send_message.execute(true)
    end
  end

  describe '.sales_nav_scrap_threads' do
    context 'when scrapping open threads' do
      it 'wants to scrap 100 threads but there is less open conversations' do
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

  xdescribe '.sales_nav_send_inmail' do
    before do
      # let's mock some methods in order to not send the inmail
    end
    it 'sends inmail' do
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
        stephane_messages = @session.sales_nav_scrap_messages(ENV.fetch('s_scrap_messages_url'))
        expect { stephane_messages.execute(scrap_value, 'TOM STOCK') }.to raise_error(ScrapIn::LeadNameMismatch) 
      end
    end

    context 'when a lead as an open conversation' do
      it 'scraps all messages from thread_url if the number of messages < scrap_value' do
        count = 0
        scrap_value = 100
        stephane_messages = @session.sales_nav_scrap_messages(ENV.fetch('s_scrap_messages_url'))
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
    end
  end
end
