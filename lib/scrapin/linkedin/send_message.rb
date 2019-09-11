module ScrapIn
  module LinkedIn
    # Send a message a lead on LinkedIn
    class SendMessage
      include Tools
      include CssSelectors::LinkedIn::SendMessage

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
        time = 0
        byebug
        while check_and_find_all(@session, message_button_css).count.zero?
          puts 'sleeping'
          sleep(0.2)
          time += 0.2
          raise 'Cannot load profile. Timeout !' if time > 60
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
        message_field = check_and_find(@session, message_field_css)
        message_field.send_keys(@message)
        puts 'Message has been written.'
      end

      def send_message
        puts 'Sending message...'
        find_and_click(send_button_css)
        puts 'Message has been sent.'
        # check, for now we suppose the message has been sent correctly
        true
      end

      def message_sent?
        puts 'Checking the message has been sent...'
        byebug
        if check_and_find_all(@session, '.msg-s-event-listitem p')[-1].text == @message
          byebug
          puts 'Confirmed'
          return true
        else
          puts "#{@error.to_s}"
          return false
        end
      end
    end
  end
end
