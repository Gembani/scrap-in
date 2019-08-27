module ScrapIn
  module SalesNavigator
    class Threads
      include Tools
      include CssSelectors::Threads
      def initialize(session)
        @session = session
      end

      def execute(num_times = 500)
        return true if num_times.zero?
        visit_messages_link
        count = 0
        
        num_times.times.each do
          item_limit = set_limit
          if count >= item_limit
            puts 'reach max open conversations'
            break
          else
            conversation = find_conversation(count)
            name = conversation.text
            conversation.click
            thread_link = @session.current_url
            yield name, thread_link
            count += 1
          end
          sleep(1.5)
        end
        true
      end
      
      def visit_messages_link
        click = check_and_find_all(@session, threads_access_button_css, wait: 5)[0].click
        wait_messages_page_to_load
        puts 'Messages have been visited.'
      end

      def wait_messages_page_to_load
        time = 0
        while check_and_find_all(@session, message_css, wait: 5).count < 2
          puts 'Waiting messages to appear'
          sleep(0.2)
          time += 0.2
          raise 'Cannot scrap conversation. Timeout !' if time > 60
        end
      end

      def find_conversation(count)
        threads_list = check_and_find(@session, threads_list_css)
        threads_list_elements = check_and_find_all(threads_list, threads_list_elements_css, wait: 5)[count]
        # byebug
        check_and_find(threads_list_elements, thread_name_css, wait: 5)
      end

      def set_limit
        threads_list = check_and_find(@session, threads_list_css)
        check_and_find_all(threads_list, loaded_threads_css, wait: 5).count
      end
    end
  end
end