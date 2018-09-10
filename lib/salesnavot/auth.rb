module Salesnavot
  # Class to Log in into Linkedin
  class Auth
    def initialize(session)
      @session = session
    end

    def email_input(type = :selector)
      type.to_sym
      return 'session_key-login' if type == :id
      '#session_key-login'
    end

    def password_input(type = :selector)
      return 'session_password-login' if type == :id
      '#session_password-login'
    end

    def login_button(type = :selector)
      return 'btn-primary' if type == :id
      '#btn-primary'
    end

    def homepage
      'https://www.linkedin.com/sales'
    end

    def login!(username, password)
      puts 'visiting login screen'
      @session.visit(homepage)

      puts 'Filling in email...'
      @session.fill_in id: email_input(:id), with: username

      puts 'Filling in password...'
      @session.fill_in id: password_input(:id), with: password

      puts 'Clicking on login button'
      @session.find(login_button).click
      @session.has_selector?('#insights-list')
      # We just need to log in. No need to wait for a css to appear
    end
  end
end
