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
      
      raise CaptchaError if security_check?
      
      enter_credentials(username, password)
      success = homepage_is_loaded?
      raise IncorrectPassword if @session.has_selector?(password_error_css, wait: 1)
      raise CaptchaError if security_check?
      raise CssNotFound, "Input with placeholder = #{search_placeholder}" unless success
    end

    private

    def security_check? 
      if @session.has_selector?(security_check_css)
        item = check_and_find_first(@session, security_check_css)
        item.text == "Let's do a quick security check"
      else
        false
      end
    end

    def homepage_is_loaded?
      try_until_true(10) do
        has_field = @session.has_field?(placeholder: search_placeholder, wait: 1)
        if !@linkedin && !has_field
          has_field = @session.has_field?(placeholder: new_sales_navigator_placeholder, wait: 1) 
        end
        has_field
      end
    end

    def current_url_already_logged
      @session.current_url == if @linkedin
                                'https://www.linkedin.com/feed/'
                              else
                                'https://www.linkedin.com/sales/homepage'
                              end
    end
      
    def enter_credentials(username, password)
      puts 'Visiting login screen'
      @session.visit(homepage)
      already_logged_in = try_until_true(3) do 
        current_url_already_logged
      end
      
      # security_check = try_until_true(5) do 
      #   @session.find()
      # end

      if already_logged_in
        puts 'already logged in'
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
