module Salesnavot
  class Session
    def initialize(username, password)
      @capybara = Capybara::Session.new(ENV.fetch('driver').to_sym)
      auth = Salesnavot::Auth.new(@capybara)
      auth.login!(username, password)
    end

    def new_lead(config)
      Salesnavot::Lead.new(config, @capybara)
    end

    def invite(sales_nav_profile_link, content)
      Salesnavot::Invite.new(sales_nav_profile_link, @capybara, content)
    end

    def sent_invites
      Salesnavot::SentInvites.new(@capybara)
    end

    def send_message(profile, message)
      Salesnavot::SendMessage.new(@capybara, profile, message)
    end

    def threads
      Salesnavot::Threads.new(@capybara)
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

    def search(identifier)
      Salesnavot::Search.new(identifier, @capybara)
    end
  end
end
