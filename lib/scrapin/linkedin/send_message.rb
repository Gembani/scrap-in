module ScrapIn
  module LinkedIn
    # Send a message a lead on LinkedIn
    class SendMessage
      include Tools
      include CssSelectors::LinkedIn::SendMessage

      def initialize(session, thread, message)
        @session = session
        @thread = thread
        @message = message
        @error = 'An error occured when sending the message.'
      end

      def execute(send = true)
        return false unless visit_profile

        write_message
        return send unless send

        send_message
        message_sent?
      end

      def visit_profile
        puts 'Visiting profile...'

        @session.visit(@thread)
        wait_messages_to_appear
      end

      def wait_messages_to_appear
        puts 'waiting messages to appear'
        messages_appear = check_until(500) do
          @session.all(messages_css).count.positive?
        end
        messages_appear
      end

      def write_message
        puts 'Writing message...'
        message_field = check_and_find(@session, message_field_css)
        message_field.send_keys(@message)
        puts 'Message has been written.'
      end

      def send_message
        puts 'Sending message...'
        find_and_click(@session, send_button_css)
        puts 'Message has been sent.'
        # check, for now we suppose the message has been sent correctly
        true
      end

      def message_sent?
        puts 'Checking the message has been sent...'
        if @session.all(messages_css)[-1].nil?
          puts @error.to_s
          return false
        elsif @session.all(messages_css)[-1].text != @message
          puts @error.to_s
          return false
        else
          puts 'Confirmed'
          return true
        end
      end
    end
  end
end
