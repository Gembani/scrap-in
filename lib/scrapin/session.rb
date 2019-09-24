module ScrapIn
  # Capybara Session
  class Session
    def initialize(username, password)
      Capybara.default_max_wait_time = 10 # Seconds
      # Capybara.default_max_wait_time = 60 # Seconds

      @capybara = Capybara::Session.new(ENV.fetch('driver').to_sym)
      # @capybara.driver.browser.manage.window.resize_to(1920, 1080)
      auth = ScrapIn::SalesNavigator::Auth.new(@capybara)
      auth.login!(username, password)
    end

    def scrap_lead(config)
      ScrapIn::ScrapLead.new(config, @capybara)
    end

    def linkedin_scrap_lead(config)
      ScrapIn::LinkedIn::ScrapLead.new(config, @capybara)
    end

    def invite(sales_nav_profile_link, content)
      ScrapIn::SalesNavigator::Invite.new(sales_nav_profile_link, @capybara, content)
    end

    def linkedin_invite(lead_url, *note)
      ScrapIn::LinkedIn::Invite.new(@capybara, lead_url)
    end

    def convert_linkedin_to_salesnav(linkedin_url)
      ScrapIn::LinkedinSalesnavConverter.new(linkedin_url, @capybara)
    end

    def sent_invites
      ScrapIn::SentInvites.new(@capybara)
    end

    def get_linkedin_data_from_name(name)
      object = ScrapIn::LinkedInDataFromName.new(@capybara)
      object.execute(name)
    end

    def get_thread_from_name(name)
      object = ScrapIn::ThreadFromName.new(@capybara)
      object.execute(name)
    end

    def linkedin_send_message(profile, message)
      ScrapIn::LinkedIn::SendMessage.new(@capybara, profile, message)
    end

    def send_inmail(profile_url, subject, message)
      ScrapIn::SalesNavigator::SendInmail.new(@capybara, profile_url, subject, message)
    end

    def threads
      ScrapIn::SalesNavigator::Threads.new(@capybara)
    end

    def sales_nav_threads
      ScrapIn::SalesNavigator::Threads.new(@capybara)
    end

    def sales_nav_messages(thread_link)
      ScrapIn::SalesNavigator::Messages.new(@capybara, thread_link)
    end

    def linkedin_messages(thread_link)
      ScrapIn::LinkedIn::Messages.new(@capybara, thread_link)
    end

    def profile_views
      ScrapIn::ProfileViews.new(@capybara)
    end

    def driver
      @capybara.driver
    end

    def friends
      ScrapIn::Friends.new(@capybara)
    end

    def search(list_identifier)
      ScrapIn::Search.new(list_identifier, @capybara)
    end
  end
end
