module ScrapIn
  module LinkedIn
    # Class which yield messages and direction in linkedin
    class ScrapMessages
      include Tools
      include CssSelectors::LinkedIn::ScrapMessages
      def initialize(session, thread_link)
        @session = session
        @thread_link = thread_link
      end
      
      def execute(number_of_messages = 20)
        raise ArgumentError.new('Parameter should be positive') unless number_of_messages.positive? # ArgumentError.new

        raise CssNotFound.new(messages_thread_css) unless visit_thread_link

        loaded_messages = load(number_of_messages)
        raise CssNotFound.new(all_messages_css) if loaded_messages.zero?

        count = loaded_messages - 1
        max = loaded_messages > number_of_messages ? number_of_messages : loaded_messages
        max.times.each do
          message = @session.all(all_messages_css)
          content = check_and_find(message[count], message_content_css).text
          direction = message[count][:class].include?(sender_css) ? :incoming : :outgoing
          count -= 1
          yield content, direction
        end
        true
      end
    
      def visit_thread_link
        @session.visit(@thread_link)
        return false unless wait_messages_to_appear

        puts 'Messages have been visited.'
        true
      end
      
      def wait_messages_to_appear
        puts 'waiting messages to appear'
        messages_appear = check_until(500) do
          @session.all(messages_thread_css).count.positive?
        end
        messages_appear
      end

      def load(number_of_messages)
        loaded_messages = count_loaded_messages
        while loaded_messages < number_of_messages && loaded_messages.positive?
          first_message = check_and_find_first(@session, all_messages_css)
          check_until(500) do
            scroll_to(first_message)
          end
          return loaded_messages if loaded_messages == count_loaded_messages

          loaded_messages = count_loaded_messages
        end
        loaded_messages
      end

      def count_loaded_messages
        @session.all(all_messages_css).count
      end
    end
  end
end