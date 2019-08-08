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
      return if @session.first(sales_messages_css).find(message_thread_css).all(message_thread_elements_css).count < 1

      loaded_messages = load
      count = loaded_messages - 1

      number_of_messages.times.each do
        if count < 1
          puts "Maximum scrapped messages reached, total [#{loaded_messages - count}]"
          break
        else
          message_content = @session.first(sales_messages_css).find(message_thread_css).all(message_thread_elements_css)[count].find(content_css).text
          sender = @session.first(sales_messages_css).find(message_thread_css).all(message_thread_elements_css)[count].first(sender_css, wait:2, visible: false)[police_css]
          direction = (sender == "Message from you") ? :outgoing : :incoming
        end
        yield message_content, direction
        count -= 1
      end
      sleep(0.5)
    end
    
    def visit_thread_link
      @session.visit(@thread_link)
      wait_messages_to_appear
      puts 'Sales messages have been visited.'
    end
    
    def wait_messages_to_appear
      time = 0
      while @session.all(sales_loaded_messages_css).count < 1
        puts 'Waiting messages to appear'
        sleep(0.2)
        time += 0.2
        raise 'Cannot scrap conversation. Timeout !' if time > 60
      end
    end

    # Only the 10 first messages are loaded in Sales, then they are loaded 10 by 10
    def load
      loaded_messages = 0
      while loaded_messages != @session.first(sales_messages_css).find(message_thread_css).all(message_thread_elements_css).count do
        loaded_messages = @session.first(sales_messages_css).find(message_thread_css).all(message_thread_elements_css).count
        item = @session.first(sales_messages_css).find(message_thread_css).all(message_thread_elements_css).first
        item.click
        sleep(2)
      end
      loaded_messages
    end
  end
end