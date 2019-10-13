module ScrapIn
  module SalesNavigator
    # Scrap threads
    class ScrapThreads
      include ScrapIn::Tools
      include CssSelectors::SalesNavigator::ScrapThreads
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
            return false if conversation == false

            name = conversation.text
            if count > 0
              old_url = @session.current_url
              conversation.click
              raise "url did not change" unless check_until(500) do  
                old_url != @session.current_url
              end
            end
            thread_link = @session.current_url
            yield name, thread_link
            count += 1
          end
          sleep(1.5)
        end
        true
      end

      def visit_messages_link
        @session.visit('https://www.linkedin.com/sales/inbox/')
        wait_messages_page_to_load
        puts 'Messages have been visited.'
      end

      def wait_messages_page_to_load
        time = 0
        while @session.all(message_css, wait: 5).count < 2
          puts 'Waiting messages to appear'
          sleep(0.2)
          time += 0.2
          raise 'Cannot scrap conversation. Timeout !' if time > 60
        end
      end

      def find_conversation(count)
        threads_list = check_and_find(@session, threads_list_css)
        threads_list_elements = threads_list.all(threads_list_elements_css, wait: 5)[count]
        return false if threads_list_elements.nil?

        check_and_find(threads_list_elements, thread_name_css, wait: 5)
      end

      def set_limit
        threads_list = check_and_find(@session, threads_list_css)
        threads_list.all(loaded_threads_css, wait: 5).count
      end
    end
  end
end
