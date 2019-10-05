require 'spec_helper'

RSpec.describe ScrapIn do
  before(:all) do
    puts 'Capybara is creating a session for all tests...'
    @session = ScrapIn::Session.new(ENV.fetch('username'), ENV.fetch('password'))
  end

  after(:all) do
    @session.driver.quit
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
      seb_link = 'https://www.linkedin.com/sales/people/ACoAAB2tnsMByAipkq4gQ5rxjAeaMynf6T2ku70,name,MoVL'

      sales_nav_scrap_lead = @session.sales_nav_scrap_lead(sales_nav_url: seb_link)
      data = sales_nav_scrap_lead.to_hash
      # puts "Error: #{scrap.error}" unless scrap.error.empty?

      expect(data[:sales_nav_url]).not_to be_nil
      expect(data[:name]).not_to be_nil
      expect(data[:location]).not_to be_nil
      expect(data[:emails].count).to be > 0
      expect(data[:phones].count).to be > 0
      expect(data[:links].count).to eq(0)
    end
  end

  describe '.linkedin_scrap_lead' do
    it 'scraps location, phones, emails and website links for a lead' do
      scrap_in = 'https://www.linkedin.com/in/scrap-in-b72a77192/'

      linkedin_scrap_lead = @session.linkedin_scrap_lead(linkedin_url: scrap_in)
      data = linkedin_scrap_lead.to_hash
      # puts "Error: #{scrap.error}" unless scrap.error.empty?

      expect(data[:linkedin_url]).not_to be_nil
      expect(data[:name]).not_to be_nil
      expect(data[:location]).not_to be_nil
      expect(data[:emails].count).to be > 0
      expect(data[:phones].count).to be > 0
      expect(data[:links].count).to eq(2)
    end
  end

  describe '.linkedin_scrap_sent_invites' do
    it 'scraps up to 40 leads names with pending invites' do
      linkedin_scrap_sent_invites = @session.linkedin_scrap_sent_invites
      linkedin_scrap_sent_invites.execute(40) do |invited_lead|
        puts invited_lead
      end
      expect(linkedin_scrap_sent_invites.invited_leads.length).to be <= 40
      expect(linkedin_scrap_sent_invites.invited_leads.length).to be >= 10
    end

    xit 'scraps up to 10000 leads names with pending invites' do
      count = 1
      number_of_invites = 10_000
      linkedin_scrap_sent_invites = @session.linkedin_scrap_sent_invites
      linkedin_scrap_sent_invites.execute(number_of_invites) do |invite|
        puts count.to_s + ' -> ' + invite.to_s
        count += 1
      end
      expect(linkedin_scrap_sent_invites.invited_leads.length).to be <= number_of_invites
    end
  end

  describe '.linkedin_profile_views' do
    it 'shows the profiles of up to 5 people who viewed our profile recently' do
      count = 1
      n = 5
      linkedin_profile_views = @session.linkedin_profile_views
      linkedin_profile_views.execute(n) do |name, time_ago|
        puts "#{count} -> #{name} , #{time_ago} ago."
        count += 1
      end
      expect(linkedin_profile_views.profile_viewed_by.length).to eq(n)
    end

    it 'shows the profiles of up to 100 people who viewed our profile recently' do
      count = 1
      n = 100
      linkedin_profile_views = @session.linkedin_profile_views
      linkedin_profile_views.execute(n) do |name, time_ago|
        puts "#{count} -> #{name} , #{time_ago} ago."
        count += 1
      end
      expect(linkedin_profile_views.profile_viewed_by.length).to be <= n
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
      message = 'Hello there'
      url = 'https://www.linkedin.com/sales/people/ACwAABOC43QB_33UK_zSdjpGT874CI8sI8O2g-Y,NAME_SEARCH,WIxj?_ntb=VRQIgoLqSS%2BxwUkvus4PVA%3D%3D'
      sales_nav_invite = @session.sales_nav_invite(url, message)
      value = sales_nav_invite.execute
      expect(value).to be true
      puts 'Invite sent !'
    end
  end

  describe '.linkedin_send_message' do
    it ' sends a message from linkedin profile to a lead' do
      linkedin_send_message = @session.linkedin_send_message('https://www.linkedin.com/in/scebula/',
                                                    'Hi, this is a test message at ' +
                                                        Time.now.strftime('%H:%M:%S').to_s +
                                                        '. Thanks!')
      linkedin_send_message.execute
    end
  end

  describe '.linkedin_scrap_friends' do
    it 'scraps friends' do
      count = 1
      @session.linkedin_scrap_friends.execute(250) do |time_ago, name, url|
        puts "#{count} -> #{name} : #{time_ago}. -> #{url}"
        count += 1
      end
      expect(count).to eq(251)
    end
  end

  describe '.linkedin_scrap_threads' do
    xit 'scraps threads' do # For now we don't care
      @session.linkedin_scrap_threads.execute(70) do |name, thread|
        puts "#{name}, #{thread}"
      end
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

  describe '.sales_nav_send_inmail' do
    before do
      # let's mock some methods in order to not send the inmail
    end
    it 'sends inmail' do
      url = 'https://www.linkedin.com/sales/people/ACwAABoqzPMBkNjA1A2yhrvf3CmyLD3fQWqTLCg,NAME_SEARCH,Q68x'
      message = 'Hello from Paris. I\'m'
      subject = 'Introduction'
      sales_nav_send_inmail = @session.sales_nav_send_inmail(url, subject, message)
      expect(sales_nav_send_inmail.execute).to be true
    end
  end

  describe '.linkedin_invite' do
    context 'Connect button is visible and no note is added' do
      it 'invite the lead' do
        lead_url = 'https://www.linkedin.com/in/valentin-piatko/'
        linkedin_invite = @session.linkedin_invite(lead_url)
        value = linkedin_invite.execute(lead_url)
        expect(value).to be(true)
      end
    end
    
    context 'Connect button is in \'More...\' section and no note is added' do
      it 'invite the lead' do
        lead_url = 'https://www.linkedin.com/in/nenad-akanovic-460aa9174/'
        linkedin_invite = @session.linkedin_invite(lead_url)
        value = linkedin_invite.execute(lead_url)
        expect(value).to be(true)
      end
    end

    context 'Connect button is visible and a note is added' do
      it 'invite the lead with a message' do
        lead_url = 'https://www.linkedin.com/in/valentin-piatko/'
        note = 'Hello, it\'s me. I was wondering if after all these years you\'d like to meet.'
        linkedin_invite = @session.linkedin_invite(lead_url, note)
        value = linkedin_invite.execute(lead_url, note)
        expect(value).to be(true)
      end
    end

    context 'Connect button is in \'More...\' section and a note is added' do
      it 'invite the lead with a message' do
        lead_url = 'https://www.linkedin.com/in/nenad-akanovic-460aa9174/'
        note = 'Hello, it\'s me. I was wondering if after all these years you\'d like to meet.'
        linkedin_invite = @session.linkedin_invite(lead_url, note)
        value = linkedin_invite.execute(lead_url, note)
        expect(value).to be(true)
      end
    end
  end

  describe '.sales_nav_scrap_messages' do
    context 'when a lead as an open conversation' do
      it 'scraps all messages from thread_url if the number of messages < scrap_value' do
        20.times do
          count = 0
          scrap_value = 100
          seb_messages = @session.sales_nav_scrap_messages('https://www.linkedin.com/sales/inbox/6564811480502460416')
          seb_messages.execute(scrap_value) do |message, direction|
            if direction == :incoming
              print 'CONTACT ->  '
            else
              print 'YOU ->  '
            end
            puts message
            count += 1
          end
          expect(count).to be < scrap_value
        end
      end

      it 'scraps the scrap_value last messages from thread_url' do
        20.times do
          count = 0
          scrap_value = 2
          # messages = @session.sales_nav_scrap_messages('https://www.linkedin.com/sales/inbox/6563813822195433472')
          messages = @session.sales_nav_scrap_messages('https://www.linkedin.com/sales/inbox/6572101845743910912')

          messages.execute(scrap_value) do |message, direction|
            if direction == :incoming
              print 'CONTACT ->  '
            else
              print 'YOU ->  '
            end
            puts message
            count += 1
          end
          expect(count).to eq(scrap_value)
        end
      end

      it 'scraps the scrap_value last messages from thread_url and scroll only for these messages to load' do
        20.times do
          count = 0
          scrap_value = 25
          seb_messages = @session.sales_nav_scrap_messages('https://www.linkedin.com/sales/inbox/6564811480502460416')
          seb_messages.execute(scrap_value) do |message, direction|
            if direction == :incoming
              print 'CONTACT ->  '
            else
              print 'YOU ->  '
            end
            puts message
            count += 1
          end
          expect(count).to eq(scrap_value)
        end
      end

      it 'Scraps correctly the sender\'s name' do
        20.times do
          count = 0
          scrap_value = 25
          messages = @session.sales_nav_scrap_messages('https://www.linkedin.com/sales/inbox/6560550015541043200')
          messages.execute(scrap_value) do |message, direction|
            if direction == :incoming
              print 'CONTACT ->  '
            else
              print 'YOU ->  '
            end
            puts message
            count += 1
          end
          expect(count).to be < scrap_value
        end
      end
    end
  end

  describe '.linkedin_scrap_messages' do
    context 'when a lead as an open conversation' do
      it do
        messages = @session.linkedin_scrap_messages('https://www.linkedin.com/messaging/thread/6260168385326256128/')
        messages.execute(13) do |message, direction|

          if direction == :incoming
            print "CONTACT ->  "
          else
            print "YOU ->  "
          end
          puts message
        end
      end
    end
  end
end
