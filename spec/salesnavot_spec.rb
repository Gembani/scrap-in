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

  it 'gets profile and image links from all leads of the list' do
    puts "Loading ...".blue
    @session.search('test_one_200').execute() do |link, image|
      unless link
        puts "NOT OK".red
      end
      expect(link).to start_with('https://www.linkedin.com/sales/people')
    end
  end

  it 'scraps phones, emails and website links for a lead' do
    seb_link = 'https://www.linkedin.com/sales/people/ACoAAB2tnsMByAipkq4gQ5rxjAeaMynf6T2ku70,name,MoVL'
    scrap = @session.scrap_lead(sales_nav_url: seb_link)
    scrap.execute
    expect(scrap.sales_nav_url).not_to be_nil
    expect(scrap.name).not_to be_nil
    expect(scrap.linkedin_url).not_to be_nil
    expect(scrap.emails.count).to be > 0
    expect(scrap.phones.count).to be > 0
    expect(scrap.links.count).to eq(0)
    expect(scrap.linkedin_url).to eq("https://www.linkedin.com/in/scebula")
  end

  xit 'scrap up to 40 leads with pending invites' do
    invites = @session.sent_invites
    invites.execute(40) do |invited_lead|
      puts invited_lead
    end
    expect(invites.invited_leads.length).to be <= 40
  end

  xit 'scrap up to 10000 leads with pending invites' do
    count = 1
    number_of_invites = 10000
    invites = @session.sent_invites
    invites.execute(number_of_invites) do |invite|
      puts count.to_s + ' -> ' + invite.to_s
      count += 1
    end
    expect(invites.invited_leads.length).to be <= number_of_invites
  end

  xit 'profile views up to 40' do
    count = 1
    n = 500
    profile_views = @session.profile_views
    profile_views.execute(n) do |name, time_ago|
      puts "#{count} -> #{name} , #{time_ago} ago."
      count += 1
    end
    expect(profile_views.profile_viewed_by.length).to be <= n
  end

  xit 'create invite already connected' do
    message = 'Hello, this is a test'
    invite = @session.invite('https://www.linkedin.com/sales/profile/323951533,F1Ig,NAME_SEARCH?moduleKey=peopleSearchResults&pageKey=sales-search3-people&contextId=8F37C172A38F1315806C569E8B2B0000&requestId=f9372319-4f38-4bae-9830-e810398675f5&action=CLICK&target=urn%3Ali%3AsalesLead%3A(-1%2C323951533)&pageNumber=0&targetEl=profilelink&position=7&trk=lss-serp-result-lead_name', message)
    if invite.execute
      puts 'invite sent'
    else
      puts invite.error
    end
  end

  xit 'from linkedin profile send message' do
    send_message = @session.send_message('https://www.linkedin.com/in/scebula/',
                                         'Hi, this is a test message at ' +
                                             Time.now.strftime('%H:%M:%S').to_s +
                                             '. Thanks!')
    send_message.execute
  end

  xit 'scrap friends' do
    @session.friends.execute(30) do |time_ago, name|
      puts name + ' -> ' + time_ago
    end
  end

  xit 'scrap threads' do
    @session.threads.execute(70) do |name, thread|
      puts "#{name}, #{thread}"
    end
  end

  xit 'scrap messages' do
    messages = @session.messages('https://www.linkedin.com/messaging/thread/6371701120393453568/')
    did_send = messages.send_greeting_message("hello world\n This message is long and blah blah blah")
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
