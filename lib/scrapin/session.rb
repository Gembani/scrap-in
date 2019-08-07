module ScrapIn
  # Capybara Session
  class Session
    def initialize(username, password)
      # Capybara.default_max_wait_time = 10 # Seconds
      Capybara.default_max_wait_time = 60 # Seconds

      @capybara = Capybara::Session.new(ENV.fetch('driver').to_sym)
      # @capybara.driver.browser.manage.window.resize_to(1920, 1080)
      auth = ScrapIn::SalesNavigator::Auth.new(@capybara)
      auth.login!(username, password)
    end

    def scrap_lead(config)
      ScrapIn::ScrapLead.new(config, @capybara)
    end

    def invite(sales_nav_profile_link, content)
      ScrapIn::Invite.new(sales_nav_profile_link, @capybara, content)
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

    def send_message(profile, message)
      ScrapIn::SendMessage.new(@capybara, profile, message)
    end

    def send_inmail(profile_url, subject, message)
      ScrapIn::SendInmail.new(@capybara, profile_url, subject, message)
    end

    def threads
      ScrapIn::Threads.new(@capybara)
    end

    def sales_nav_threads
      ScrapIn::SalesNavThreads.new(@capybara)
    end

    def messages(thread_link)
      ScrapIn::Messages.new(@capybara, thread_link)
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
