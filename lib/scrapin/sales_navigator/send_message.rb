module ScrapIn
  module SalesNavigator
    # Send a message to a lead on Sales Navigator
    class SendMessage
      include Tools
      include CssSelectors::SalesNavigator::SendMessage
      def initialize(session, thread, message)
        @session = session
        @thread = thread
        @message = message
      end

      def execute(send = true)
        return false unless visit_thread

        write_message
        send_message(send)
        message_sent?
      end

      def visit_thread
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

      def send_message(send)
        puts 'Sending message...'
        send_button = check_and_find(@session, send_button_css)
        return send unless send

        send_button.click
        puts 'Message has been sent.'
        true
      end

      def message_sent?
        puts 'Checking the message has been sent...'
        return false if @session.all(messages_css)[-1].nil?

        return false if @session.all(messages_css)[-1].text != @message

        puts 'Confirmed'
        true
      end
    end
  end
end
