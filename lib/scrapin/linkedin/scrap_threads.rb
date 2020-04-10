module ScrapIn
  module LinkedIn
    class ScrapThreads
      include Tools
      include CssSelectors::LinkedIn::ScrapThreads
      def initialize(session)
        @session = session
      end

      def execute(num_times = 10)
        raise ArgumentError, 'Parameter should be positive' unless num_times.positive?
       
        visit_messages_link
        count = 0

        num_times.times.each do
          item_limit = set_limit
          if count >= item_limit
            puts 'reach max open conversations'
            break
          else
            conversation = find_conversation(count)
            scroll_to(conversation)
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
        @session.visit('https://www.linkedin.com/messaging/')
        puts 'Messages have been visited.'
     end

      def find_conversation(count)
        threads_list_2 = check_and_find(@session, threads_block_count_css(count))
        check_and_find(threads_list_2, one_thread_css, wait: 5)
      end

      def set_limit
        threads_list = check_and_find(@session, threads_block_css)
        threads_list.all(threads_list_css, wait: 5).count
      end
    end
  end
end
