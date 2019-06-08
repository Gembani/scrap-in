require 'spec_helper'

RSpec.describe Salesnavot do
  before(:all) do
    puts 'Capybara is creating a session for all tests...'
    @session = Salesnavot::Session.new(ENV.fetch('username'), ENV.fetch('password'))
  end

  after(:all) do
    @session.driver.quit
  end
  it 'has a version number_of_invites' do
    expect(Salesnavot::VERSION).not_to be nil
  end

  describe '#Search' do
    it 'gets lead from page 1' do
      @search = @session.search('test_one_200')
      next_page_to_process = @search.execute(1) do |link, image|
        expect(link).to start_with('https://www.linkedin.com/sales/people')
      end
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

    it 'tries to go to the tousandth page of the list, doesnt find it and return the first page' do
      @search = @session.search('test_one_200')
      next_page_to_process = @search.execute(20) do |_link, _image|
      end
      expect(next_page_to_process).to eq(1)
    end
  end

  it 'convert_linkedin_to_salesnav' do
    scrap = @session.convert_linkedin_to_salesnav('https://www.linkedin.com/in/fabricelenoble/')
    expect(scrap.execute).to eq('https://www.linkedin.com/sales/people/ACoAAADWUwgBctzvFTKAW_3OhL5rc-fpKquTURM,name,2Qv9')

  end

  it 'get_linkedin_data_from_name' do
    expect(@session.get_linkedin_data_from_name("Emma Donovan")).to eq(linkedin_url: "https://www.linkedin.com/in/emmadonovan1", salesnav_url:"https://www.linkedin.com/sales/people/ACoAAAAAJ_kBu6vzRwww0KpB2oF4ljYmj1O21z8,name,QOK6")
  end


    it 'get friend thread' do
      expect(@session.get_thread_from_name("Emma Donovan")).to eq("https://www.linkedin.com/messaging/thread/S490732917_3")
    end



  it 'scraps location, phones, emails and website links for a lead' do
    seb_link = 'https://www.linkedin.com/sales/people/ACoAAB2tnsMByAipkq4gQ5rxjAeaMynf6T2ku70,name,MoVL'
    scrap = @session.scrap_lead(sales_nav_url: seb_link)
    scrap.execute
    puts "Error: #{scrap.error}" unless scrap.error.empty?
    expect(scrap.sales_nav_url).not_to be_nil
    expect(scrap.name).not_to be_nil
    expect(scrap.location).not_to be_nil
    expect(scrap.emails.count).to be > 0
    expect(scrap.phones.count).to be > 0
    expect(scrap.links.count).to eq(0)
  end

  it 'scrap up to 40 leads with pending invites' do
    invites = @session.sent_invites
    invites.execute(40) do |invited_lead|
      puts invited_lead
    end
    expect(invites.invited_leads.length).to be <= 40
    expect(invites.invited_leads.length).to be >= 10
  end

  xit 'scrap up to 10000 leads with pending invites' do
    count = 1
    number_of_invites = 10_000
    invites = @session.sent_invites
    invites.execute(number_of_invites) do |invite|
      puts count.to_s + ' -> ' + invite.to_s
      count += 1
    end
    expect(invites.invited_leads.length).to be <= number_of_invites
  end

  it 'profile views up to 40' do
    count = 1
    n = 500
    profile_views = @session.profile_views
    profile_views.execute(n) do |name, time_ago|
      puts "#{count} -> #{name} , #{time_ago} ago."
      count += 1
    end
    expect(profile_views.profile_viewed_by.length).to be <= n
  end

  describe '#Salesnavot::Invite' do
    before do
      allow_any_instance_of(Salesnavot::Invite).to receive(:click_and_connect).and_return(true)
      allow_any_instance_of(Salesnavot::Invite).to receive(:lead_invited?).and_return(true)
    end
    it 'creates invite already connected' do ## Integration
      message = 'Hello there'
      invite = @session.invite('https://www.linkedin.com/sales/people/ACwAAChfmuYBvjIbCcBAEM0npwYdZ1t_yG29Y6w,NAME_SEARCH,bJYg?trk=d_sales2_nav_typeahead_entitysuggestion', message)

      value = invite.execute
      expect(value).to be true
      puts 'Invite sent !'
    end
  end

  xit 'from linkedin profile send message' do
    send_message = @session.send_message('https://www.linkedin.com/in/scebula/',
                                         'Hi, this is a test message at ' +
                                         Time.now.strftime('%H:%M:%S').to_s +
                                         '. Thanks!')
    send_message.execute
  end

  it 'scrap friends' do
    count = 1
    @session.friends.execute(250) do |time_ago, name, url|
      puts "#{count} -> #{name} : #{time_ago}. -> #{url}"
      count = count + 1
    end
    expect(count).to eq(251)
  end

  xit 'scrap threads' do
    @session.threads.execute(70) do |name, thread|
      puts "#{name}, #{thread}"
    end
  end


  xit 'scrap messages' do
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
  end
end
