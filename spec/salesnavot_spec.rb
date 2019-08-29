require 'spec_helper'

RSpec.describe ScrapIn do
  before(:all) do
    puts 'Capybara is creating a session for all tests...'
    @session = ScrapIn::Session.new(ENV.fetch('username'), ENV.fetch('password'))
  end

  after(:all) do
    @session.driver.quit
  end
  xit 'has a version number_of_invites' do
    expect(ScrapIn::VERSION).not_to be nil
  end

  describe '#Search' do

    it 'gets lead from all pages' do
      @search = @session.search('test_one_200')
      max_page = 13
      page = 1
      until page == max_page
        puts "TESTING PAGE = #{page}"
        found_links = []
        next_page_to_process = @search.execute(page) do |link, image|
          expect(link).to start_with('https://www.linkedin.com/sales/people')
          found_links << link
        end
        expect(found_links.size).to eq(25)
        expect(next_page_to_process).to eq(page + 1)
        page += 1
      end
    end

    it 'gets lead from page 1' do
      @search = @session.search('test_one_200')
      found_links = []
      next_page_to_process = @search.execute(1) do |link, image|
        expect(link).to start_with('https://www.linkedin.com/sales/people')
        found_links << link
      end
      expect(found_links.size).to eq(25)
      expect(next_page_to_process).to eq(2)
    end


    it 'gets profile and image links from all leads of the second page of the list and return the next page' do
      @search = @session.search('test_one_200')
      next_page_to_process = @search.execute(3) do |link, image|
        expect(link).to start_with('https://www.linkedin.com/sales/people')
      end
      expect(next_page_to_process).to eq(4)
    end

    it 'gets profile and image links from all leads of the twelfth page of the list and return the next page' do
      @search = @session.search('test_one_200')
      next_page_to_process = @search.execute(12) do |link, _image|
        expect(link).to start_with('https://www.linkedin.com/sales/people')
      end
      expect(next_page_to_process).to eq(13)
    end

    it 'gets leads form the last page' do
      @search = @session.search('test_one_200')
      found_links = []
      next_page_to_process = @search.execute(13) do |link, image|
        expect(link).to start_with('https://www.linkedin.com/sales/people')
        found_links << link
      end
      expect(found_links.size).to eq(9)
      expect(next_page_to_process).to eq(14)
    end

    it 'tries to go to the twentieth page of the list, doesnt find it and return the first page' do
      @search = @session.search('test_one_200')
      next_page_to_process = @search.execute(20) do |_link, _image|
      end
      expect(next_page_to_process).to eq(1)
    end
  end

  it 'convert_linkedin_to_salesnav' do
    convert = @session.convert_linkedin_to_salesnav('https://www.linkedin.com/in/fabricelenoble/')
    # convert = @session.convert_linkedin_to_salesnav('https://www.linkedin.com/in/gautierv/')
    expect(convert.execute).to eq('https://www.linkedin.com/sales/people/ACoAAADWUwgBctzvFTKAW_3OhL5rc-fpKquTURM,name,2Qv9')

  end

  it 'get_linkedin_data_from_name' do
    expect(@session.get_linkedin_data_from_name("Emma Donovan")).to eq(linkedin_url: "https://www.linkedin.com/in/emmadonovan1", salesnav_url:"https://www.linkedin.com/sales/people/ACoAAAAAJ_kBu6vzRwww0KpB2oF4ljYmj1O21z8,name,QOK6")
  end


  it 'gets friend thread' do
    expect(@session.get_thread_from_name("Emma Donovan")).to eq("https://www.linkedin.com/messaging/thread/S490732917_3")
  end



  it 'scraps location, phones, emails and website links for a lead' do
    seb_link = 'https://www.linkedin.com/sales/people/ACoAAB2tnsMByAipkq4gQ5rxjAeaMynf6T2ku70,name,MoVL'
    
    scrap = @session.scrap_lead(sales_nav_url: seb_link)
    data = scrap.to_hash
    # puts "Error: #{scrap.error}" unless scrap.error.empty?

    expect(data[:sales_nav_url]).not_to be_nil
    expect(data[:name]).not_to be_nil
    expect(data[:location]).not_to be_nil
    expect(data[:emails].count).to be > 0
    expect(data[:phones].count).to be > 0
    expect(data[:links].count).to eq(0)
    byebug
  end

  it 'scraps location, phones, emails and website links for a lead' do
    seb_link = 'https://www.linkedin.com/in/scebula/'
    
    scrap = @session.linkedin_scrap_lead(linkedin_url: seb_link)
    data = scrap.to_hash
    # puts "Error: #{scrap.error}" unless scrap.error.empty?

    expect(data[:sales_nav_url]).not_to be_nil
    expect(data[:name]).not_to be_nil
    expect(data[:location]).not_to be_nil
    expect(data[:emails].count).to be > 0
    expect(data[:phones].count).to be > 0
    expect(data[:links].count).to eq(0)
    byebug
  end

  it 'scraps up to 40 leads names with pending invites' do
    invites = @session.sent_invites
    invites.execute(40) do |invited_lead|
      puts invited_lead
    end
    expect(invites.invited_leads.length).to be <= 40
    expect(invites.invited_leads.length).to be >= 10
  end

  xit 'scraps up to 10000 leads names with pending invites' do
    count = 1
    number_of_invites = 10_000
    invites = @session.sent_invites
    invites.execute(number_of_invites) do |invite|
      puts count.to_s + ' -> ' + invite.to_s
      count += 1
    end
    expect(invites.invited_leads.length).to be <= number_of_invites
  end

  it 'shows the profiles of up to 5 people who viewed our profile recently' do
    count = 1
    n = 5
    profile_views = @session.profile_views
    profile_views.execute(n) do |name, time_ago|
      puts "#{count} -> #{name} , #{time_ago} ago."
      count += 1
    end
    expect(profile_views.profile_viewed_by.length).to be <= n
  end

  it 'shows the profiles of up to 100 people who viewed our profile recently' do
    count = 1
    n = 100
    profile_views = @session.profile_views
    profile_views.execute(n) do |name, time_ago|
      puts "#{count} -> #{name} , #{time_ago} ago."
      count += 1
    end
    expect(profile_views.profile_viewed_by.length).to be <= n
  end

  describe '#Salesnavot::Invite' do
    # before do
    #   allow_any_instance_of(Salesnavot::Invite).to receive(:click_and_connect).and_return(true)
    #   allow_any_instance_of(Salesnavot::Invite).to receive(:lead_invited?).and_return(true)
    #   allow_any_instance_of(Salesnavot::Invite).to receive(:pending_after_invite?).and_return(true)
    # end
    it 'sends invite and send a message' do ## Integration
      message = 'Hello there'
      invite = @session.invite('https://www.linkedin.com/sales/people/ACwAAAH0sfYBxITLbDpjmA7L5iAPE_WtUzz1-c0,NAME_SEARCH,IoU3', message)
      value = invite.execute
      expect(value).to be true
      puts 'Invite sent !'
    end
  end

  it ' sends a message from linkedin profile to a lead' do
    send_message = @session.send_message('https://www.linkedin.com/in/scebula/',
                                         'Hi, this is a test message at ' +
                                         Time.now.strftime('%H:%M:%S').to_s +
                                         '. Thanks!')
    send_message.execute
  end

  it 'scraps friends' do
    count = 1
    @session.friends.execute(250) do |time_ago, name, url|
      puts "#{count} -> #{name} : #{time_ago}. -> #{url}"
      count = count + 1
    end
    expect(count).to eq(251)
  end

  xit 'scraps threads' do #For now we don't care
    @session.threads.execute(70) do |name, thread|
      puts "#{name}, #{thread}"
    end
  end

  context 'when scrapping open threads' do
    it 'wants to scrap 100 threads but there is less open conversations' do
      count = 0
      @session.sales_nav_threads.execute(100) do |name, thread|
        puts "#{name}, #{thread}"
        count += 1
      end
      expect(count).to be < 100
    end

    it 'scraps 10 threads, does not need to scroll down to load older conversations' do
      count = 0
      @session.sales_nav_threads.execute(10) do |name, thread|
        puts "#{name}, #{thread}"
        count += 1
      end
      expect(count).to be > 0
    end

    it 'scraps 30 threads, needs to scroll down 1 time to load older conversations' do
      count = 0
      @session.sales_nav_threads.execute(30) do |name, thread|
        puts "#{name}, #{thread}"
        count += 1
      end
      expect(count).to be > 0
    end
  end

  describe '#send_inmail' do
    it 'sends inmail' do
      url = 'https://www.linkedin.com/sales/people/ACwAABoqzPMBkNjA1A2yhrvf3CmyLD3fQWqTLCg,NAME_SEARCH,Q68x'
      message = 'Hello from Paris. I\'m'
      subject = 'Introduction'
      send_inmail = @session.send_inmail(url, subject, message)
      expect(send_inmail.execute).to be true
    end
  end

  context 'when a lead as an open conversation' do
    it 'scraps all messages from thread_url if the number of messages < scrap_value' do
      20.times do
        count = 0
        scrap_value = 100
        seb_messages = @session.sales_nav_messages('https://www.linkedin.com/sales/inbox/6564811480502460416')
        seb_messages.execute(scrap_value) do |message, direction|
          
          if direction == :incoming
            print "CONTACT ->  "
          else
            print "YOU ->  "
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
        # messages = @session.sales_nav_messages('https://www.linkedin.com/sales/inbox/6563813822195433472')
        messages = @session.sales_nav_messages('https://www.linkedin.com/sales/inbox/6572101845743910912')
        
        messages.execute(scrap_value) do |message, direction|
          
          if direction == :incoming
            print "CONTACT ->  "
          else
            print "YOU ->  "
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
        seb_messages = @session.sales_nav_messages('https://www.linkedin.com/sales/inbox/6564811480502460416')
        seb_messages.execute(scrap_value) do |message, direction|
          
          if direction == :incoming
            print "CONTACT ->  "
          else
            print "YOU ->  "
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
        messages = @session.sales_nav_messages('https://www.linkedin.com/sales/inbox/6560550015541043200')
        messages.execute(scrap_value) do |message, direction|

          if direction == :incoming
            print "CONTACT ->  "
          else
            print "YOU ->  "
          end
          puts message
          count += 1
        end
        expect(count).to be < scrap_value 
      end
    end
  end
end

#messages = @session.messages('https://www.linkedin.com/messaging/thread/6371701120393453568/')
#did_send = messages.send_greeting_message("hello world\n This message is long and blah blah blah")
# messages.execute(100) do | message, direction|
#
#   if direction == :incoming
#     print "CONTACT ->  "
#   else
#     print "YOU ->  "
#   end
#   puts message
# end