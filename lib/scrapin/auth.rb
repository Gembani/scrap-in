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
      
      raise CaptchaError if is_security_check?
      
      enter_credentials(username, password)
      success = homepage_is_loaded?
      raise IncorrectPassword if @session.has_selector?(password_error_css, wait: 1)
      raise CaptchaError if is_security_check?
      raise CssNotFound, "Input with placeholder = #{search_placeholder}" unless success
    end

    private
    def is_security_check? 
      if @session.has_selector?('main h1')
        return @session.all('main h1').first.text == "Let's do a quick security check"
      else
        return false
      end
    end
    def homepage_is_loaded?
        check_until(10) do
        @session.has_field?(placeholder: search_placeholder, wait: 1)
      end
    end
    def current_url_already_logged
      if @linkedin
        @session.current_url == 'https://www.linkedin.com/feed/'
      else
        @session.current_url == 'https://www.linkedin.com/sales/homepage'
      end
    end
      
    def enter_credentials(username, password)
      puts 'Visiting login screen'
      @session.visit(homepage)
      already_logged_in = check_until(5) do 
        current_url_already_logged
      end
      
      # security_check = check_until(5) do 
      #   @session.find()
      # end

      if already_logged_in
        puts "already logged in"
        return
      end
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
      'https://www.linkedin.com'
    end

    def sales_navigator_homepage
      'https://www.linkedin.com/sales'
    end
  end
end
