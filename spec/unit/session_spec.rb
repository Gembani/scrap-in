require 'spec_helper'

RSpec.describe ScrapIn::Session do


  let(:username) { 'username' }
  let(:password) { 'password' }
  let(:driver) { 'driver' }
  let(:capybara_session) { instance_double('Capybara::Session') }
  let(:auth) { instance_double('ScrapIn::Auth') }

  [true, false].each do |linkedin|
    let(:subject) { ScrapIn::Session.new(username, password, linkedin) }

    platform_name = linkedin ? 'linkedin' : 'sales navigator'
    before do
      allow(ENV).to receive(:fetch).with('driver').and_return(driver)
      allow(Capybara::Session).to receive(:new).with(driver.to_sym).and_return(capybara_session)
      allow(auth).to receive(:login!).with(username, password, linkedin)
      allow(ScrapIn::Auth).to receive(:new).with(capybara_session).and_return(auth)
    end

    describe '.intialize' do
      context "when we want to log into #{platform_name}" do
        after { ScrapIn::Session.new(username, password, linkedin) }
        it 'should have created a new session' do
          expect(Capybara::Session).to receive(:new).with(driver.to_sym).and_return(capybara_session)
        end
        it "should have logged in into #{platform_name}" do
          expect(ScrapIn::Auth).to receive(:new).with(capybara_session).and_return(auth)
          expect(auth).to receive(:login!).with(username, password, linkedin)
        end
      end
    end

    describe '.sales_nav_scrap_lead' do
      let(:scrap_lead) { instance_double('ScrapIn::SalesNavigator::ScrapLead') }
      let(:config) { instance_double('Hash') }
      before do
        allow(ScrapIn::SalesNavigator::ScrapLead).to receive(:new).with(config, capybara_session).and_return(scrap_lead)
      end
      it 'should call the correct initializer' do
        expect(ScrapIn::SalesNavigator::ScrapLead).to receive(:new).with(config, capybara_session).and_return(scrap_lead)
        result = subject.sales_nav_scrap_lead(config)
        expect(result).to be(scrap_lead)
      end
    end

    describe '.linkedin_scrap_lead' do
      let(:scrap_lead) { instance_double('ScrapIn::LinkedIn::ScrapLead') }
      let(:config) { instance_double('Hash') }
      before do
        allow(ScrapIn::LinkedIn::ScrapLead).to receive(:new).with(config, capybara_session).and_return(scrap_lead)
      end
      it 'should call the correct initializer' do
        expect(ScrapIn::LinkedIn::ScrapLead).to receive(:new).with(config, capybara_session).and_return(scrap_lead)
        result = subject.linkedin_scrap_lead(config)
        expect(result).to be(scrap_lead)
      end
    end

    describe '.invite' do
      let(:sales_nav_profile_link) { 'profile_link' }
      let(:content) { 'content' }
      let(:invite) { instance_double('ScrapIn::SalesNavigator::Invite') }
      before do
        allow(ScrapIn::SalesNavigator::Invite).to receive(:new).with(sales_nav_profile_link, capybara_session, content).and_return(invite)
      end
      it 'should call the correct initializer' do
        expect(ScrapIn::SalesNavigator::Invite).to receive(:new).with(sales_nav_profile_link, capybara_session, content).and_return(invite)
        result = subject.invite(sales_nav_profile_link, content)
        expect(result).to be(invite)
      end
    end

    describe '.linkedin_invite' do
      let(:lead_url) { 'lead_url' }
      let(:note) { 'note' }
      let(:linkedin_invite) { instance_double('ScrapIn::Linkedin::Invite') }
      before do
        allow(ScrapIn::LinkedIn::Invite).to receive(:new).with(capybara_session, lead_url).and_return(linkedin_invite)
      end
      it 'should call the correct initializer' do
        expect(ScrapIn::LinkedIn::Invite).to receive(:new).with(capybara_session, lead_url).and_return(linkedin_invite)
        result = subject.linkedin_invite(lead_url, note)
        expect(result).to be(linkedin_invite)
      end
    end

    describe '.sent_invites' do
      let(:sent_invites) { instance_double('ScrapIn::Linkedin::Invite') }
      before do
        allow(ScrapIn::SentInvites).to receive(:new).with(capybara_session).and_return(sent_invites)
      end
      it 'should call the correct initializer' do
        expect(ScrapIn::SentInvites).to receive(:new).with(capybara_session).and_return(sent_invites)
        result = subject.sent_invites
        expect(result).to be(sent_invites)
      end
    end

    describe '.linkedin_send_message' do
      let(:profile_url) { 'profile_url' }
      let(:message) { 'message' }
      let(:linkedin_send_message) { instance_double('ScrapIn::Linkedin::SendMessage') }
      before do
        allow(ScrapIn::LinkedIn::SendMessage).to receive(:new).with(capybara_session, profile_url, message).and_return(linkedin_send_message)
      end
      it 'should call the correct initializer' do
        expect(ScrapIn::LinkedIn::SendMessage).to receive(:new).with(capybara_session, profile_url, message).and_return(linkedin_send_message)
        result = subject.linkedin_send_message(profile_url, message)
        expect(result).to be(linkedin_send_message)
      end
    end

    describe '.send_inmail' do
      let(:profile_url) { 'profile_url' }
      let(:mail_subject) { 'subject' }
      let(:message) { 'message' }
      let(:send_inmail) { instance_double('ScrapIn::SalesNavigator::SendInmail') }
      before do
        allow(ScrapIn::SalesNavigator::SendInmail).to receive(:new).with(capybara_session, profile_url, mail_subject, message).and_return(send_inmail)
      end
      it 'should call the correct initializer' do
        expect(ScrapIn::SalesNavigator::SendInmail).to receive(:new).with(capybara_session, profile_url, mail_subject, message).and_return(send_inmail)
        result = subject.send_inmail(profile_url, mail_subject, message)
        expect(result).to be(send_inmail)
      end
    end

    describe '.linkedin_threads' do
      let(:linkedin_threads) { instance_double('ScrapIn::Linkedin::Threads') }
      before do
        allow(ScrapIn::LinkedIn::Threads).to receive(:new).with(capybara_session).and_return(linkedin_threads)
      end
      it 'should call the correct initializer' do
        expect(ScrapIn::LinkedIn::Threads).to receive(:new).with(capybara_session).and_return(linkedin_threads)
        result = subject.linkedin_threads
        expect(result).to be(linkedin_threads)
      end
    end

    describe '.sales_nav_threads' do
      let(:sales_nav_threads) { instance_double('ScrapIn::SalesNavigator::Threads') }
      before do
        allow(ScrapIn::SalesNavigator::Threads).to receive(:new).with(capybara_session).and_return(sales_nav_threads)
      end
      it 'should call the correct initializer' do
        expect(ScrapIn::SalesNavigator::Threads).to receive(:new).with(capybara_session).and_return(sales_nav_threads)
        result = subject.sales_nav_threads
        expect(result).to be(sales_nav_threads)
      end
    end

    describe '.sales_nav_messages' do
      let(:thread_link) { 'thread_link' }
      let(:sales_nav_messages) { instance_double('ScrapIn::SalesNavigator::ScrapMessages') }
      before do
        allow(ScrapIn::SalesNavigator::ScrapMessages).to receive(:new).with(capybara_session, thread_link).and_return(sales_nav_messages)
      end
      it 'should call the correct initializer' do
        expect(ScrapIn::SalesNavigator::ScrapMessages).to receive(:new).with(capybara_session, thread_link).and_return(sales_nav_messages)
        result = subject.sales_nav_messages(thread_link)
        expect(result).to be(sales_nav_messages)
      end
    end

    describe '.linkedin_scrap_messages' do
      let(:thread_link) { 'thread_link' }
      let(:linkedin_scrap_messages) { instance_double('ScrapIn::LinkedIn::ScrapMessages') }
      before do
        allow(ScrapIn::LinkedIn::ScrapMessages).to receive(:new).with(capybara_session, thread_link).and_return(linkedin_scrap_messages)
      end
      it 'should call the correct initializer' do
        allow(ScrapIn::LinkedIn::ScrapMessages).to receive(:new).with(capybara_session, thread_link).and_return(linkedin_scrap_messages)
        result = subject.linkedin_scrap_messages(thread_link)
        expect(result).to be(linkedin_scrap_messages)
      end
    end

    describe '.linkedin_profile_views' do
      let(:linkedin_profile_views) { instance_double('ScrapIn::LinkedIn::ProfileViews') }
      before do
        allow(ScrapIn::LinkedIn::ProfileViews).to receive(:new).with(capybara_session).and_return(linkedin_profile_views)
      end
      it 'should call the correct initializer' do
        expect(ScrapIn::LinkedIn::ProfileViews).to receive(:new).with(capybara_session).and_return(linkedin_profile_views)
        result = subject.linkedin_profile_views
        expect(result).to be(linkedin_profile_views)
      end
    end

    describe '.driver' do
      let(:capybara_driver) { instance_double('Capybara::Selenium::Driver') }
      before do
        allow(capybara_session).to receive(:driver).and_return(capybara_driver)
      end
      it 'should call the correct initializer' do
        expect(capybara_session).to receive(:driver).and_return(capybara_driver)
        result = subject.driver
        expect(result).to be(capybara_driver)
      end
    end

    describe '.friends' do
      let(:friends) { instance_double('ScrapIn::Friends') }
      before do
        allow(ScrapIn::Friends).to receive(:new).with(capybara_session).and_return(friends)
      end
      it 'should call the correct initializer' do
        expect(ScrapIn::Friends).to receive(:new).with(capybara_session).and_return(friends)
        result = subject.friends
        expect(result).to be(friends)
      end
    end

    describe '.search' do
      let(:list_identifier) { 'list_identifier' }
      let(:search) { instance_double('ScrapIn::Search') }
      before do
        allow(ScrapIn::Search).to receive(:new).with(list_identifier, capybara_session).and_return(search)
      end
      it 'should call the correct initializer' do
        expect(ScrapIn::Search).to receive(:new).with(list_identifier, capybara_session).and_return(search)
        result = subject.search(list_identifier)
        expect(result).to be(search)
      end
    end
  end
end

