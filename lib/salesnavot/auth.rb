#captcha error
class CaptchaError < StandardError
end

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
      raise 'Cannot find email field' unless @session.has_selector?(email_input(:id))
      username_field =  @session.find(email_input(:id))
      username_field.click
      sleep(1)
      puts "Filling in email..."
      puts "Email #{username}"
    
      username_field.send_keys(username)
      sleep(1)
      password_field = @session.find(password_input(:id))
      puts 'Filling in password...'
      sleep(1)
      password_field.click
      puts "Filling in password...#{password}"
    
      password_field.send_keys(password)
      puts 'Clicking on login button'
      sleep(1)
      password_field.send_keys(:enter)

      loop do
        break unless @session.has_xpath?(captcha_xpath, wait: 10)
        puts "Captcha verification waiting for result"
        sleep(3)
      end
      raise 'Login failed !' unless @session.has_xpath?(alert_header_xpath)
    end
    

    def homepage
      'https://www.linkedin.com/sales'
    end
  end
end
