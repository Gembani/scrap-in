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

      @session.visit(homepage)
      wait_for_human if security_check?
      return true if homepage_is_loaded?
      return wait_for_manual_login if username.to_s.empty? || password.to_s.empty?

      enter_credentials(username, password)
      raise IncorrectPassword if @session.has_selector?(password_error_css, wait: 1)

      wait_for_human if security_check?
      raise CssNotFound, "Input with placeholder = #{search_placeholder}" unless homepage_is_loaded?

      true
    end

    private

    # LinkedIn sends us to /checkpoint/ for captchas, email pins and 2FA.
    def security_check?
      return true if @session.current_url.include?(checkpoint_path)
      return false unless @session.has_selector?(security_check_css, wait: 1)

      @session.first(security_check_css).text == "Let's do a quick security check"
    end

    # Rather than failing on a security check, give a human the chance to solve it through VNC.
    def wait_for_human
      timeout = Integer(ENV.fetch('CAPTCHA_TIMEOUT', 300))
      puts "Security check at #{@session.current_url}"
      puts "Solve it in the browser (#{ENV.fetch('VNC_URL', 'http://localhost:7900')}), waiting #{timeout}s..."
      solved = try_until_true(timeout, 1) { !security_check? }
      raise CaptchaError, "Security check not solved within #{timeout}s" unless solved
    end

    # No credentials configured: let a human log in over VNC, the Chrome profile keeps the cookies.
    def wait_for_manual_login
      timeout = Integer(ENV.fetch('CAPTCHA_TIMEOUT', 300))
      @session.visit(login_page)
      puts "No credentials set. Log in at #{ENV.fetch('VNC_URL', 'http://localhost:7900')}, waiting #{timeout}s..."
      logged_in = try_until_true(timeout, 1) do
        @session.current_url.start_with?(homepage) && homepage_is_loaded?
      end
      raise CssNotFound, "Input with placeholder = #{search_placeholder}" unless logged_in

      true
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

    def enter_credentials(username, password)
      puts 'Visiting login screen'
      @session.visit(login_page)

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

    def login_page
      'https://www.linkedin.com/login'
    end

    def linkedin_homepage
      'https://www.linkedin.com/feed/'
    end

    def sales_navigator_homepage
      'https://www.linkedin.com/sales/homepage'
    end
  end
end
