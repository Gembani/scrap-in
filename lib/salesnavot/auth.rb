#Class to Log in into Linkedin
module Salesnavot
  class Auth
    def initialize(session)
      @session = session
    end

    def email_input(type = :selector)
      type.to_sym
      if type == :id
        return 'session_key-login'
      end
      return '#session_key-login'
    end

    def password_input(type = :selector)
      if type == :id
        return 'session_password-login'
      end
      return '#session_password-login'
    end
    
    def login_button(type = :selector)
      if type == :id
        return 'btn-primary'
      end
      return '#btn-primary'
    end

    def homepage
      "https://www.linkedin.com/sales"
    end
    
    def login!(username, password)
      puts "visiting login screen"
      @session.visit(homepage)

      puts "Filling in email..."
      @session.fill_in id: email_input(:id), with: username

      puts "Filling in password..."
      @session.fill_in id: password_input(:id), with: password

      puts "Clicking on login button"
      @session.find(login_button).click

      # We just need to log in. No need to wait for a css to appear
    end

  end
end
