module ScrapIn
  # Capybara Session
  class Session
    include LinkedInMethods
    include SalesNavigatorMethods

    def initialize(username, password, linkedin = false, capybara = false)
      Capybara.default_max_wait_time = 10 # Seconds
      # Capybara.default_max_wait_time = 60 # Seconds
      if (capybara)
        @capybara = capybara
      else
        @capybara = Capybara::Session.new(ENV.fetch('driver').to_sym)
      end
      auth = ScrapIn::Auth.new(@capybara)
      auth.login!(username, password, linkedin)
    end

    def driver
      @capybara.driver
    end
  end
end
