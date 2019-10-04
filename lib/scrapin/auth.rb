module ScrapIn
  # Class to Log in into Linkedin or SalesNavigator
  class Auth
    include CssSelectors::Auth
    include Tools
    def initialize(session)
      @session = session
    end

    def login!(username, password, linkedin = false)
      @linkedin = linkedin
      enter_credentials(username, password)
      success = homepage_is_loaded?
      raise IncorrectPassword if @session.has_selector?(password_error_css, wait: 1)
      raise CssNotFound, "Input with placeholder = #{search_placeholder}" unless success
    end

    private

    def homepage_is_loaded?
      check_until(10) do
        @session.has_field?(placeholder: search_placeholder, wait: 1)
      end
    end

    def enter_credentials(username, password)
      puts 'Visiting login screen'
      @session.visit(homepage)

      puts "Filling in email... -> #{username}"
      username_field = check_and_find(@session, username_input_css)
      username_field.click
      sleep(1)
      username_field.send_keys(username)
      sleep(1)

      puts 'Filling in password...'
      password_field = check_and_find(@session, password_input_css)
      sleep(1)
      password_field.click
      password_field.send_keys(password)

      puts 'Clicking on login button'
      sleep(1)
      password_field.send_keys(:enter)
    end

    def homepage
      @linkedin ? linkedin_homepage : sales_navigator_homepage
    end

    def search_placeholder
      @linkedin ? linkedin_placeholder : sales_navigator_placeholder
    end

    def linkedin_homepage
      'https://www.linkedin.com/login'
    end

    def sales_navigator_homepage
      'https://www.linkedin.com/sales'
    end
  end
end
