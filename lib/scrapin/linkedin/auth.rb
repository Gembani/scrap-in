module ScrapIn
  module LinkedIn
    # Class to Log in into Linkedin
    class Auth
      include CssSelectors::LinkedIn::Auth
      def initialize(session)
        @session = session
      end

      def login!(username, password)
        puts 'Visiting login screen'
        @session.visit(homepage)

        puts "Filling in email... -> #{username}"
        username_field = @session.check_and_find(email_input(:id))
        username_field.click
        sleep(1)
        username_field.send_keys(username)
        sleep(1)

        puts 'Filling in password...'
        password_field = @session.check_and_find(password_input(:id))
        sleep(1)
        password_field.click
        password_field.send_keys(password)
        
        puts 'Clicking on login button'
        sleep(1)
        password_field.send_keys(:enter)
      end      

      def homepage
        'https://www.linkedin.com/sales'
      end
    end
  end
end