require "spec_helper"
RSpec.describe Salesnavot do
  let (:session) {Salesnavot::Session.new(ENV.fetch('username'), ENV.fetch('password'))}
  after(:each) do
    session.driver.quit
  end

  it "has a version number" do
    expect(Salesnavot::VERSION).not_to be nil
  end

  it "get search from links" do

    session.search('test_one_200').execute do |link|
      puts link
    end
  end

  it "create lead" do
    lead = session.new_lead({sales_nav_url: "https://www.linkedin.com/sales/profile/568261266,esdT,NAME_SEARCH?"})
    lead.scrap
  end


  it 'create invite already connected' do
    invite = session.invite("https://www.linkedin.com/sales/profile/230110692,mp07,NAME_SEARCH?")
    if invite.execute
      puts "inivte sent"
    else
      puts invite.error
    end
  end





  it 'create sent invites' do
    session.sent_invites.execute do |invite|
      puts invite
    end
  end

  it 'scrap friends' do
    session.sent_invites.execute(200) do |time_str, name|
      puts time_str, name
    end
  end

  it 'scrap profile views' do
    session.sent_invites.execute(200) do |time_str, name|
      puts time_str, name
    end
  end

end
