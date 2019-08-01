module Salesnavot

  class SendInmail
    include Tools
    include CssSelectors::SendMessage
    include CssSelectors::Invite # for friend? method (degree_css)

    def initialize(session, profile_url, subject, message)
      @session = session
      @profile_url = profile_url
      @message = message
      @subject = subject
      @error = 'An error occured when sending the inmail.'
    end

    def execute
      # Go to profile
      # Ensure lead is not friend
      # Click on message link
      # Write the message
      # Send the message
      visit_profile
      byebug
      friend = friend?
      byebug
      open_message_window
      write_message
      send_message
      message_sent?
    end

    def visit_profile
      puts 'Visiting profile...'

      @session.visit(@profile_url)

      button_found = check_until(500) do
        @session.has_selector?('button', text: 'Message', wait: 0)
      end
      raise 'Error: Button not found' unless button_found
      
      puts 'Profile has been visited.'
    end

    def friend?
      degree_css = '.profile-topcard-person-entity__content span'
      text = '1st'
      raise css_error(degree_css) unless @session.has_selector?(degree_css, wait:5)
      @session.has_selector?(degree_css, text: text, wait:5)
    end

    def open_message_window
      puts 'Opening message window...'
      @session.click_button 'Message'
      puts 'Message window has been opened.'
    end
    
    def write_message
      puts 'Writing message...'
      message_field= @session.find(message_field_css)
      message_field.send_keys(@message)
      puts 'Message has been written.'
    end

    def send_message
      puts 'Sending message...'
      @session.find(send_button_css).click
      puts 'Message has been sent.'
      # check, for now we suppose the message has been sent correctly
      true
    end

    def message_sent?
      puts 'Checking the message has been sent...'
      if @session.all('.msg-s-event-listitem p')[-1].text == @message
        puts 'Confirmed'
        return true
      else
        @error
        return false
      end
    end
  end
end
