module ScrapIn
  # Capybara Session
  class Session
    def initialize(username, password, linkedin = false)
      Capybara.default_max_wait_time = 10 # Seconds
      # Capybara.default_max_wait_time = 60 # Seconds

      @capybara = Capybara::Session.new(ENV.fetch('driver').to_sym)
      auth = ScrapIn::Auth.new(@capybara)
      auth.login!(username, password, linkedin)
    end

    def driver
      @capybara.driver
    end

    def sales_nav_scrap_lead(config)
      ScrapIn::SalesNavigator::ScrapLead.new(config, @capybara)
    end

    def sales_nav_invite(sales_nav_profile_link, content)
      ScrapIn::SalesNavigator::Invite.new(sales_nav_profile_link, @capybara, content)
    end

    def sales_nav_send_inmail(profile_url, subject, message)
      ScrapIn::SalesNavigator::SendInmail.new(@capybara, profile_url, subject, message)
    end

    def sales_nav_scrap_threads
      ScrapIn::SalesNavigator::ScrapThreads.new(@capybara)
    end

    def sales_nav_scrap_messages(thread_link)
      ScrapIn::SalesNavigator::ScrapMessages.new(@capybara, thread_link)
    end

    def sales_nav_scrap_search_list(list_identifier)
      ScrapIn::SalesNavigator::ScrapSearchList.new(list_identifier, @capybara)
    end

    def linkedin_scrap_lead(config)
      ScrapIn::LinkedIn::ScrapLead.new(config, @capybara)
    end

    def linkedin_invite(lead_url, *note)
      ScrapIn::LinkedIn::Invite.new(@capybara, lead_url)
    end

    def linkedin_scrap_sent_invites
      ScrapIn::LinkedIn::ScrapSentInvites.new(@capybara)
    end

    def linkedin_send_message(profile, message)
      ScrapIn::LinkedIn::SendMessage.new(@capybara, profile, message)
    end

    def linkedin_scrap_threads
      ScrapIn::LinkedIn::ScrapThreads.new(@capybara)
    end

    def linkedin_scrap_messages(thread_link)
      ScrapIn::LinkedIn::ScrapMessages.new(@capybara, thread_link)
    end

    def linkedin_profile_views
      ScrapIn::LinkedIn::ProfileViews.new(@capybara)
    end

    def linkedin_scrap_friends
      ScrapIn::LinkedIn::ScrapFriends.new(@capybara)
    end
  end
end
