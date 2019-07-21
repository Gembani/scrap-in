module Salesnavot
  # Capybara Session
  class Session
    def initialize(username, password)
      #Capybara.default_max_wait_time = 10 # Seconds
      Capybara.default_max_wait_time = 60 # Seconds
      @capybara = Capybara::Session.new(ENV.fetch('driver').to_sym)
      @capybara.driver.browser.manage.window.resize_to(1920, 1080)
      auth = Salesnavot::Auth.new(@capybara)
      auth.login!(username, password)
    end

    def scrap_lead(config)
      Salesnavot::ScrapLead.new(config, @capybara)
    end

    def invite(sales_nav_profile_link, content)
      Salesnavot::Invite.new(sales_nav_profile_link, @capybara, content)
    end

    def convert_linkedin_to_salesnav(linkedin_url)
      Salesnavot::LinkedinSalesnavConverter.new(linkedin_url, @capybara)
    end

    def sent_invites
      Salesnavot::SentInvites.new(@capybara)
    end

    def get_linkedin_data_from_name(name)
      object = Salesnavot::LinkedInDataFromName.new(@capybara)
      object.execute(name)
    end

    def get_thread_from_name(name)
      object = Salesnavot::ThreadFromName.new(@capybara)
      object.execute(name)
    end

    def send_message(profile, message)
      Salesnavot::SendMessage.new(@capybara, profile, message)
    end

    def threads
      Salesnavot::Threads.new(@capybara)
    end

    def messages(thread_link)
      Salesnavot::Messages.new(@capybara, thread_link)
    end

    def profile_views
      Salesnavot::ProfileViews.new(@capybara)
    end

    def driver
      @capybara.driver
    end

    def friends
      Salesnavot::Friends.new(@capybara)
    end

    def search(list_identifier)
      Salesnavot::Search.new(list_identifier, @capybara)
    end
  end
end
