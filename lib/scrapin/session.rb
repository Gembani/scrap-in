module ScrapIn
  # Capybara Session
  class Session
    include LinkedInMethods
    include SalesNavigatorMethods

    attr_reader :capybara

    def initialize(username, password, linkedin = false, capybara = false)
      Capybara.default_max_wait_time = 10 # Seconds
      @capybara = capybara || Capybara::Session.new(ENV.fetch('driver', 'scrapin_driver').to_sym)
      auth = ScrapIn::Auth.new(@capybara)
      auth.login!(username, password, linkedin)
    end

    def driver
      @capybara.driver
    end
  end
end
