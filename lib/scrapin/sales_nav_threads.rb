module ScrapIn
  class SalesNavThreads
    include Tools
    include CssSelectors::SalesNavThreads
    def initialize(session)
      @session = session
    end

    def execute(num_times = 500)
      visit_messages_link
      count = 0

      num_times.times.each do
        sleep(2)
        break unless @session.all(threads_list_css).nil?
        item = @session.find(threads_list_css).all(loaded_threads_css).first
        item_limit = @session.find(threads_list_css).all(loaded_threads_css).count
        if count >= item_limit
          puts 'item = nil'
          # count = 0
          break
        else
          name = @session.find(threads_list_elements_css)[count].find(thread_name_css).text
          name_click = @session.find(threads_list_elements_css)[count].find(thread_name_css).click
          thread_link = @session.current_url
          yield name, thread_link
          count += 1
        end
        sleep(0.5)
      end
      puts "/!\\ #{count} /!\\".colorize(:blue)
    end

    def visit_messages_link
      @session.all(threads_access_button_css)[0].click
      wait_messages_page_to_load
      puts 'Messages have been visited.'
    end

    def wait_messages_page_to_load
      time = 0
      # Linkedin display first a first li with a text inside and the last perso we have talked to. The other conversation are loaded at the same time, or nearly almost.
      while @session.all(message_css).count < 2
        puts 'waiting messages to appear'
        sleep(0.2)
        time += 0.2
        raise 'Cannot scrap conversation. Timeout !' if time > 60
      end
    end
  end
end