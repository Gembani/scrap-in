module ScrapIn
  class SalesNavThreads
    include Tools
    include CssSelectors::SalesNavThreads
    def initialize(session)
      @session = session
    end

    def execute(num_times = 500)
      visit_messages_link
      check_all_css
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
    end
    
    def check_all_css
      raise CssNotFound.new(threads_list_css) unless @session.has_selector?(threads_list_css, wait: 5)
      raise CssNotFound.new(threads_list_elements_css) unless @session.has_selector?(threads_list_elements_css, wait: 5)
      raise CssNotFound.new(loaded_threads_css) unless @session.has_selector?(loaded_threads_css, wait: 5)
      raise CssNotFound.new(thread_name_css) unless @session.has_selector?(thread_name_css, wait: 5)
    end
    
    def visit_messages_link
      raise CssNotFound.new(threads_access_button_css) unless @session.has_selector?(threads_access_button_css, wait: 5)
      click = @session.all(threads_access_button_css)[0].click
      wait_messages_page_to_load
      puts 'Messages have been visited.'
    end

    def wait_messages_page_to_load
      time = 0
      # Linkedin display first a first li with a text inside and the last person we have talked to. The other conversations are loaded at the same time, or nearly almost.
      while @session.all(message_css).count < 2
        puts 'Waiting messages to appear'
        sleep(0.2)
        time += 0.2
        raise 'Cannot scrap conversation. Timeout !' if time > 60
      end
    end

    def find_conversation(count)
      threads_list = @session.find(threads_list_css)
      threads_list_elements = threads_list.all(threads_list_elements_css)[count]
      threads_list_elements.find(thread_name_css)
    end

    def set_limit
      threads_list = @session.find(threads_list_css)
      threads_list.all(loaded_threads_css).count
    end
  end
end