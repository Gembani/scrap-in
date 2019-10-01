module ScrapIn
  module SalesNavigator
    # Class to Log in into Sales Navigator
    class Auth
      include Tools
      include CssSelectors::SalesNavigator::Auth
      def initialize(session)
        @session = session
      end

      def login!(username, password)
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
        alert_page_loaded = check_until(1000) do
          @session.has_selector?(alert_header_css)
        end
        raise IncorrectPassword if @session.has_selector?(password_error_css, wait: 1)
        raise CssNotFound, alert_header_css unless alert_page_loaded
      end

      def homepage
        'https://www.linkedin.com/sales'
      end
    end
  end
end