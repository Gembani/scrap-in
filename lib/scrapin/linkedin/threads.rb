module ScrapIn
  module LinkedIn
    class Threads
      include Tools
      include CssSelectors::LinkedIn::Threads
      def initialize(session)
        @session = session
      end

      def execute(num_times = 500)
        visit_messages_link
        count = 0

        num_times.times.each do
          item = check_and_find_all(@session, threads_block_count_css(count)).first
          if item.nil?
            puts 'item = nil'
            count = 0
            break
          else
            name = check_and_find(item, one_thread_css).text
            thread_link = item.find('a')[:href]
            yield name, thread_link
            scroll_to(item)
            count += 1
          end
          sleep(0.5)
        end
      end

      def visit_messages_link
        @session.visit('https://www.linkedin.com/messaging/')
        wait_messages_page_to_load
        puts 'Messages have been visited.'
      end

      def wait_messages_page_to_load
        time = 0
        # Linkedin display first a first li with a text inside and the last perso we have talked to. The other conversation are loaded a the same time, or nearly almost.
        while check_and_find_all(@session, threads_block_css).count < 2
          puts 'waiting messages to appear'
          sleep(0.2)
          time += 0.2
          raise 'Cannot scrap conversation. Timeout !' if time > 60
        end
      end
    end
  end
end