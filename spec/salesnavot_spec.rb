require "spec_helper"

RSpec.describe Salesnavot do
  let (:session) {
    Salesnavot::Session.new(ENV.fetch('username'), ENV.fetch('password'))
  }

  before(:each) do
  end

  after(:each) do
  #  session.driver.quit
  #
  end
  it "has a version number" do
    expect(Salesnavot::VERSION).not_to be nil
  end

  it "gets search from links" do
    # session = Salesnavot::Session.new(ENV.fetch('username'), ENV.fetch('password'))
    session.driver.save_screenshot('logging.png')
    session.search('test_one_200').execute do |link|
      puts link
      expect(link).to start_with("https://www.linkedin.com/sales/profile/")
      expect(link).to end_with("NAME_SEARCH")
    end
    session.driver.save_screenshot('search.png')

    session.driver.quit
  end

  it "creates lead" do
    lead = session.new_lead({sales_nav_url: "https://www.linkedin.com/sales/profile/568261266,esdT,NAME_SEARCH?"})
    lead.scrap
    expect(lead.sales_nav_url).not_to be_nil
    expect(lead.name).not_to be_nil
    expect(lead.linkedin_url).not_to be_nil
  end

  it 'sent_invites up to 40 (less than one page)' do
    session.sent_invites.execute(40) do |invite|
      puts invite
    end
  end

  it 'sent_invites up to 230 (more than one page)' do
    count = 1
    session.sent_invites.execute(230) do |invite|
      puts count.to_s + " -> " + invite.to_s
      count = count + 1
    end
  end

  it 'profile views' do
    session.profile_views.execute do |invite|
      puts invite
  it 'profile views up to 40' do
    session.profile_views.execute(40) do |time_ago, name|
      puts name + " -> " + time_ago
    end
  end

  it 'profile views up to 200' do
    session.profile_views.execute(200) do |time_ago, name|
      puts name + " -> " + time_ago
    end
  end

  xit 'create invite already connected' do
    invite = session.invite("https://www.linkedin.com/sales/profile/323951533,F1Ig,NAME_SEARCH?moduleKey=peopleSearchResults&pageKey=sales-search3-people&contextId=8F37C172A38F1315806C569E8B2B0000&requestId=f9372319-4f38-4bae-9830-e810398675f5&action=CLICK&target=urn%3Ali%3AsalesLead%3A(-1%2C323951533)&pageNumber=0&targetEl=profilelink&position=7&trk=lss-serp-result-lead_name")
    if invite.execute
      puts "invite sent"
    else
      puts invite.error
    end
  end

  it 'create sent invites' do
    session.sent_invites.execute do |invite|
      puts invite
    end
  end

  xit 'from linkedin profile send message' do
    session.send_message('https://www.linkedin.com/in/scebula/',
      'Hi, this is a test message at ' + Time.now.strftime("%H:%M:%S").to_s + ". Thanks!")
  end

  it 'scrap friends' do
    session.friends.execute(200) do | name|
      puts  name
    end
  end

  it 'scrap profile views' do
    session.sent_invites.execute(200) do |time_str, name|
      puts time_str, name
    end
  end

  it 'scrap threads' do
    session.threads.execute(1) do |name, thread|
      puts "#{name}, #{thread}"
    end


  end

  it 'scrap messages' do

    messages = session.messages('https://www.linkedin.com/messaging/thread/6371701120393453568/')
    did_send = messages.send_greeting_message("hello world\n This message is long and blah blah blah")
    puts "hello"
    # messages.execute(100) do | message, direction|
    #   if direction == :incoming
    #     print "CONTACT ->  "
    #   else
    #     print "YOU ->  "
    #   end
    #   puts message
    # end
  end


end
