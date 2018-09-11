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
      @session.fill_in id: email_input(:id), with: username

      puts 'Filling in password...'
      @session.fill_in id: password_input(:id), with: password

      puts 'Clicking on login button'
      @session.find(login_button).click
      raise 'Login failed !' unless @session.has_selector?(insight_list_css)
    end

    def homepage
      'https://www.linkedin.com/sales'
    end
  end
end
