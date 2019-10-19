module ScrapIn
  module SalesNavigator
    class SendMessageProfile
      include Tools
      include CssSelectors::SalesNavigator::SendMessageProfile
      def initialize(session, profile)
        @session = session
        @profile = profile
      end

      def visit
        if @session.current_url != @profile
          @session.visit(@profile)
        end
        true
      end

      def write_message(message)
        puts 'Writing message...'
        button = check_and_find(@session, profile_send_button)
        button.click
        message_field = check_and_find(@session, 'textarea')
        message_field.send_keys(message)
        puts 'Message has been written.'
      end

      def send_message(send)
        puts 'Sending message...'
        button_field = check_and_find(@session, profile_send_message_button)
        return send unless send
        button_field.click
        puts 'Message has been sent.'
      end

      def message_sent?(message)
        sleep(2)
        true
      end
    end
  end
end