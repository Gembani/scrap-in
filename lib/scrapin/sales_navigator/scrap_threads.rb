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

            if count > 0
              old_url = @session.current_url
              conversation.click
              raise 'url did not change' unless try_until_true(5, 5) do  
                old_url != @session.current_url
              end
            end
            # name = conversation.text
            name = find_lead_name
            link = find_lead_link
            thread_link = @session.current_url
            yield name, thread_link, link
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
        raise 'No conversations loaded' unless try_until_true(3) do 
          @session.all(message_css).count > 2
        end
      end

      def find_conversation(count)
        
        threads_list = check_and_find(@session, threads_list_css)
        threads_list_elements = threads_list.all(threads_list_elements_css)[count]
        return false if threads_list_elements.nil?

        check_and_find(threads_list_elements, thread_name_css)
      end

      def find_lead_link
        check_and_find(@session, lead_link_css)[:href]
      end
      
      def find_lead_name
        check_and_find(@session, lead_name_css).text
      end

      def set_limit
        threads_list = check_and_find(@session, threads_list_css)
        threads_list.all(loaded_threads_css).count
      end
    end
  end
end
