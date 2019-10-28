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
	
	describe '.linkedin_scrap_lead' do
    it 'scraps location, phones, emails and website links for a lead' do
      scrap_in = 'https://www.linkedin.com/in/scrap-in-b72a77192/'
      linkedin_scrap_lead = @session.linkedin_scrap_lead(linkedin_url: scrap_in, get_sales_nav_url: true)
      data = linkedin_scrap_lead.to_hash()
      expect(data[:sales_nav_url]).not_to be_nil
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

    it 'scraps up to 10000 leads names with pending invites' do
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
	
	describe '.linkedin_send_message' do
    it ' sends a message from linkedin profile to a lead' do
      linkedin_send_message = @session.linkedin_send_message(ENV.fetch('l_send_message_url'),
                                                    'Hi, this is a test message at ' +
                                                        Time.now.strftime('%H:%M:%S').to_s +
                                                        '. Thanks!')
      linkedin_send_message.execute(false)
    end
	end
	
	describe '.linkedin_scrap_friends' do
    it 'scraps friends' do
      count = 1
      @session.linkedin_scrap_friends.execute(10) do |name, time_ago, url|
        puts "#{count} -> #{name} : #{time_ago}. -> #{url}"
        count += 1
      end
      expect(count).to eq(11)
    end
  end

  describe '.linkedin_scrap_threads' do
    it 'scraps threads' do
      @session.linkedin_scrap_threads.execute(70) do |name, thread|
        puts "#{name}, #{thread}"
      end
    end
	end
	
	describe '.linkedin_invite' do #change it
		# Warning: This test sends real invitations.
    context 'Connect button is visible and no note is added' do
      it 'invite the lead' do
        linkedin_invite = @session.linkedin_invite(ENV.fetch('l_invite_url'))
        value = linkedin_invite.execute(ENV.fetch('l_invite_url'), '', false)
        expect(value).to be(true)
      end
    end
    
    context 'Connect button is in \'More...\' section and no note is added' do
      it 'invite the lead' do
        linkedin_invite = @session.linkedin_invite(ENV.fetch('l_invite_url_2'))
        value = linkedin_invite.execute(ENV.fetch('l_invite_url_2'), '', false)
        expect(value).to be(true)
      end
    end

    context 'Connect button is visible and a note is added' do
      it 'invite the lead with a message' do
				linkedin_invite = @session.linkedin_invite(ENV.fetch('l_invite_url'), ENV.fetch('l_invite_note'))
        value = linkedin_invite.execute(ENV.fetch('l_invite_url'), ENV.fetch('l_invite_note'), false)
        expect(value).to be(true)
      end
    end

    context 'Connect button is in \'More...\' section and a note is added' do
      it 'invite the lead with a message' do
        linkedin_invite = @session.linkedin_invite(ENV.fetch('l_invite_url_2'), ENV.fetch('l_invite_note'))
        value = linkedin_invite.execute(ENV.fetch('l_invite_url_2'), ENV.fetch('l_invite_note'), false)
        expect(value).to be(true)
      end
    end
	end
	
	describe '.linkedin_scrap_messages' do
    context 'when a lead as an open conversation' do
      it do
        messages = @session.linkedin_scrap_messages(ENV.fetch('l_scrap_messages_url'))
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