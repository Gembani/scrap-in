module ScrapIn
  module SalesNavigator
    class SendMessageThread
      include Tools
      
      include CssSelectors::SalesNavigator::SendMessageThread
      def initialize(session, thread)
        @session = session
        @thread = thread
      end

      def visit
        @session.visit(@thread) if @session.current_url != @thread
        wait_messages_to_appear
      end

      def wait_messages_to_appear
        puts 'waiting messages to appear'
        messages_appear = try_until_true(3) do
          @session.all(messages_css).count.positive?
        end
        messages_appear
      end

      def write_message(message)
        puts 'Writing message...'
        message_field = check_and_find(@session, message_field_css)
        message_field.send_keys(message)
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

      def message_sent?(message)
        puts 'Checking the message has been sent...'
        return false if @session.all(messages_css)[-1].nil?

        return false if @session.all(messages_css)[-1].text != message

        puts 'Confirmed'
        true
      end
    end
  end
end
