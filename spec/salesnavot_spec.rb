require "spec_helper"
RSpec.describe Salesnavot do
  let (:session) {
    Salesnavot::Session.new(ENV.fetch('username'), ENV.fetch('password'))
  }

  before(:each) do
  end

  after(:each) do
  #  session.driver.quit
  end

  it "has a version number" do
    expect(Salesnavot::VERSION).not_to be nil
  end

  xit "gets search from links" do
    # session = Salesnavot::Session.new(ENV.fetch('username'), ENV.fetch('password'))
    session.driver.save_screenshot('logging.png')
    session.search('test_one_200').execute do |link|
      puts link
    end
    session.driver.save_screenshot('search.png')

    session.driver.quit
  end

  xit "creates lead" do
    lead = session.new_lead({sales_nav_url: "https://www.linkedin.com/sales/profile/568261266,esdT,NAME_SEARCH?"})
    lead.scrap
  end

  xit 'create invite already connected' do
    invite = session.invite("https://www.linkedin.com/sales/profile/230110692,mp07,NAME_SEARCH?")
    if invite.execute
      puts "invite sent"
    else
      puts invite.error
    end
  end

  xit 'create sent invites' do
    session.sent_invites.execute do |invite|
      puts invite
    end
  end

  xit 'from linkedin profile send message' do
    send_message = session.send_message('https://www.linkedin.com/in/nicholasstock/', 
      'Test message at : ' + Time.now.strftime("%H:%M:%S").to_s + ".")
    unless send_message.execute
      puts send_message.error
    end
  end

  xit 'scrap profile views' do
    session.sent_invites.execute(200) do |time_str, name|
      puts time_str, name
    end
  end

  it 'scrap threads' do
    threads = session.threads
    threads.execute(14)
    threads.display_names_and_thread_links
  end

end
