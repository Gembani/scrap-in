module ScrapIn
  module LinkedIn
    # Send a message to a lead on LinkedIn
    class SendMessage
      include Tools
      include CssSelectors::LinkedIn::SendMessage

      # The conversation url once the message is sent, when LinkedIn navigated to it
      attr_reader :thread_url

      def initialize(session, thread, message)
        @session = session
        @thread = thread
        @message = message
        @error = 'An error occured when sending the message.'
      end

      def execute
        return false unless visit_profile

        write_message
        send_message
        sent = message_sent?
        @thread_url = current_thread_url if sent
        sent
      end

      # Works on an existing thread url, on a compose url (messaging/compose/?recipient=...),
      # or on a profile url (linkedin.com/in/...) of a connection for a first message
      def visit_profile
        puts 'Visiting thread...'

        @session.visit(@thread)
        open_message_overlay if profile_url?
        wait_message_field_to_appear
      end

      def profile_url?
        @thread.include?('linkedin.com/in/')
      end

      def open_message_overlay
        card = check_and_find(@session, profile_top_card_css, wait: 10)
        check_and_find(card, profile_message_button_css, wait: 5).click
      end

      def current_thread_url
        url = @session.current_url
        url if url.include?(thread_path)
      end

      def wait_message_field_to_appear
        puts 'waiting message field to appear'
        try_until_true(3) do
          @session.has_selector?(message_field_css)
        end
      end

      def write_message
        puts 'Writing message...'
        message_field = check_and_find(@session, message_field_css)
        message_field.send_keys(@message)
        puts 'Message has been written.'
      end

      def send_message
        puts 'Sending message...'
        send_button = check_and_find(@session, send_button_css)

        send_button.click
        puts 'Message has been sent.'
        # check, for now we suppose the message has been sent correctly
        true
      end

      def message_sent?
        puts 'Checking the message has been sent...'
        sent = try_until_true(10, 1) { last_message_text == @message }
        puts(sent ? 'Confirmed' : @error)
        sent
      end

      def last_message_text
        @session.all(messages_css).last&.text
      end
    end
  end
end
