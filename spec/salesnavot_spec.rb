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
    end
    session.driver.save_screenshot('search.png')

    session.driver.quit
  end

  it "creates lead" do
    lead = session.new_lead({sales_nav_url: "https://www.linkedin.com/sales/profile/568261266,esdT,NAME_SEARCH?"})
    lead.scrap
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
    byebug
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
