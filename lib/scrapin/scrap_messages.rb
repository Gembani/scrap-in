module ScrapIn
  # Class which yield messages and direction in sales conversation
  module ScrapMessages
    include Tools
    
    def initialize(session, thread_link)
      @session = session
      @thread_link = thread_link
    end

    def execute(number_of_messages = 20, lead_name = false)
      visit_thread_link
      loaded_messages = load(number_of_messages)
    
      confirm_lead(lead_name) if lead_name
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
        end
        yield message_content, sender(message)
        count -= 1
      end
      sleep(0.5)
      true
    end
    
    def confirm_lead(lead_name)
      lead_name_in_thread = check_and_find(@session, lead_name_css).text
      raise LeadNameMismatch.new(lead_name, lead_name_in_thread) unless lead_name_in_thread.include?(lead_name)
    end

    def visit_thread_link
      @session.visit(@thread_link) if @session.current_url != @thread_link
      wait_messages_to_appear
      puts 'Sales messages have been visited.'
    end

    def wait_messages_to_appear
      raise 'Cannot scrap conversation. Timeout !' unless check_until(3) do
        puts 'Waiting messages to appear'
        @session.all(loaded_messages_css, wait: 5).count > 0
      end
    end

    # Only the 10 first messages are loaded in Sales, then they are loaded 10 by 10
    def load(number_of_messages)
      loaded_messages = count_loaded_messages
      while loaded_messages < number_of_messages
        message_thread = find_message_thread
        item = check_and_find_first(message_thread, message_thread_elements_css, wait: 5)
        scroll_up_to(item)
        sleep(4)
        return loaded_messages if loaded_messages == count_loaded_messages

        loaded_messages = count_loaded_messages
      end
      loaded_messages
    end

    def find_message_thread
      sales_messages = check_and_find_first(@session, messages_css, wait: 5)
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
