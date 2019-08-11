module Salesnavot
  class SalesNavMessages
    include Tools
    include CssSelectors::SalesNavMessages

    def initialize(session, thread_link)
      @session = session
      @thread_link = thread_link
    end

    def execute(number_of_messages = 20)
      visit_thread_link
      check_all_css

      loaded_messages = load(number_of_messages)
      count = loaded_messages - 1

      number_of_messages.times.each do
        if count < 1
          puts "Maximum scrapped messages reached, total [#{loaded_messages - count}]"
          break
        else
          message_content = @session.first(sales_messages_css).find(message_thread_css).all(message_thread_elements_css)[count].find(content_css).text
          sender = @session.first(sales_messages_css).find(message_thread_css).all(message_thread_elements_css)[count].first(sender_css, wait: 2, visible: false)['innerHTML'].strip
          direction = (sender == "You") ? :outgoing : :incoming
        end
        yield message_content, direction
        count -= 1
      end
      sleep(0.5)
    end

    def check_all_css
      raise CssNotFound.new(sales_messages_css) unless @session.has_selector?(sales_messages_css, wait: 5)
      raise CssNotFound.new(message_thread_css) unless @session.has_selector?(message_thread_css, wait: 5)
      raise CssNotFound.new(message_thread_elements_css) unless @session.has_selector?(message_thread_elements_css, wait: 5, minimum: 4) # The 3 first are for 'Forward', 'Archive' and 'Mark as unread'
      raise CssNotFound.new(content_css) unless @session.has_selector?(content_css, wait: 5)
      raise CssNotFound.new(sender_css) unless @session.has_selector?(sender_css, wait: 5)
    end
    
    def visit_thread_link
      @session.visit(@thread_link)
      wait_messages_to_appear
      puts 'Sales messages have been visited.'
    end
    
    def wait_messages_to_appear
      time = 0
      raise CssNotFound.new(sales_loaded_messages_css) unless @session.has_selector?(sales_loaded_messages_css, wait: 5)
      while @session.all(sales_loaded_messages_css).count < 1
        puts 'Waiting messages to appear'
        sleep(0.2)
        time += 0.2
        raise 'Cannot scrap conversation. Timeout !' if time > 60
      end
    end

    # Only the 10 first messages are loaded in Sales, then they are loaded 10 by 10
    def load(number_of_messages)
      loaded_messages = 0
      while loaded_messages < number_of_messages do
        return loaded_messages if loaded_messages == @session.first(sales_messages_css).find(message_thread_css).all(message_thread_elements_css).count
        loaded_messages = @session.first(sales_messages_css).find(message_thread_css).all(message_thread_elements_css).count
        item = @session.first(sales_messages_css).find(message_thread_css).all(message_thread_elements_css).first
        item.click
        sleep(4)
      end
      loaded_messages
    end
  end
end