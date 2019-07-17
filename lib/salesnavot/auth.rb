module Salesnavot
  # Class to Log in into Linkedin
  class Auth
    include CssSelectors::Auth
    def initialize(session)
      @session = session
    end

    def login!(username, password)
      puts 'Visiting login screen'
      @session.visit(homepage)
      puts 'Filling in email...'
      username_field =  @session.find(email_input(:id))
      username_field.click 
      username_field.send_keys(username)
      
      password_field = @session.find(password_input(:id))
      puts 'Filling in password...'
      password_field.click
      password_field.send_keys(password)
      puts 'Clicking on login button'
      password_field.send_keys(:enter)
      raise 'Login failed !' unless @session.has_selector?(alert_header_css)
    end

    def homepage
      'https://www.linkedin.com/sales'
    end
  end
end
