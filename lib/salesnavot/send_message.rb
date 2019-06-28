module Salesnavot

  class SendMessage
    include Tools
    include CssSelectors::SendMessage

    def initialize(session, profile, message)
      @session = session
      @profile = profile
      @message = message
      @error = 'An error occured when sending the message.'
    end

    def execute
      visit_profile
      open_message_window
      write_message
      send_message
      message_sent?
    end

    def visit_profile
      puts 'Visiting profile...'

      @session.visit(@profile)

      while @session.all('button.pv-s-profile-actions--message').count == 0
        puts 'sleeping'
        sleep(0.2)
      end
      puts 'Profile has been visited.'
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
