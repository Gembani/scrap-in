module ScrapIn
  module SalesNavigator
    # Class which yield messages and direction in sales conversation
    class Messages
      include Tools
      include CssSelectors::SalesNavigator::Messages

      def initialize(session, thread_link)
        @session = session
        @thread_link = thread_link
      end

      def execute(number_of_messages = 20)
        return true unless number_of_messages.positive?

        visit_thread_link

        loaded_messages = load(number_of_messages)
        count = loaded_messages - 1

        number_of_messages.times.each do
          if count < 1
            count += 1 # When there is not enough messages to scrap the first one is "beginnning of the conversation"
            # and should be ignore
            puts "Maximum scrapped messages reached, total [#{loaded_messages - count}]"
            break
          else
            message = get_message(count)
            message_content = check_and_find(message, content_css, wait: 5)['innerHTML']
            sender = check_and_find_first(message, sender_css, wait: 2, visible: false)['innerHTML'].strip
            direction = sender == 'You' ? :outgoing : :incoming
          end
          yield message_content, direction
          count -= 1
        end
        sleep(0.5)
        true
      end

      def visit_thread_link
        @session.visit(@thread_link)
        wait_messages_to_appear
        puts 'Sales messages have been visited.'
      end

      def wait_messages_to_appear
        time = 0
        while @session.all(sales_loaded_messages_css, wait: 5).count < 1
          puts 'Waiting messages to appear'
          sleep(0.2)
          time += 0.2
          raise 'Cannot scrap conversation. Timeout !' if time > 60
        end
      end

      # Only the 10 first messages are loaded in Sales, then they are loaded 10 by 10
      def load(number_of_messages)
        loaded_messages = count_loaded_messages
        while loaded_messages < number_of_messages
          message_thread = find_message_thread
          item = message_thread.all(message_thread_elements_css, wait: 5).first
          item_exist = check_until(500) do
            !item.nil?
          end
          raise 'Item does not exist. Cannot scroll!' unless item_exist

          scroll_down_to(item)
          sleep(4)
          return loaded_messages if loaded_messages == count_loaded_messages

          loaded_messages = count_loaded_messages
        end
        loaded_messages
      end

      def find_message_thread
        sales_messages = check_and_find_first(@session, sales_messages_css, wait: 5)
        check_and_find(sales_messages, message_thread_css, wait: 5)
      end

      def count_loaded_messages
        message_thread = find_message_thread
        message_thread.all(message_thread_elements_css, wait: 5).count
      end

      def get_message(count)
        message_thread = find_message_thread
        message_thread.all(message_thread_elements_css, wait: 5)[count]
      end
    end
  end
end
