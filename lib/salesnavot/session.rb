


Capybara.register_driver :browserstack do |app|
  driver = Capybara::Selenium::Driver.new(app,
    :browser => :remote,
    :url => ENV.fetch('hud_url'),
    :desired_capabilities => {"browser": "chrome", 'chromeOptions': {
        'args': ['no-sandbox', 'headless', 'disable-gpu',"window-size=1920,1080"]
    } }
  )
  driver
end


module Salesnavot
  class Session
    def initialize(username, password)

      @capybara = Capybara::Session.new(:browserstack)
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
