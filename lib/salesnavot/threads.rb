module Salesnavot
  class Threads
    def initialize(session)
      @session = session
      @names_and_thread_links = []
    end

    def execute(threads_number)
      visit_messages_link
      get_threads_links(threads_number)
    end

    def visit_messages_link
      @session.visit("https://www.linkedin.com/messaging/")
      wait_messages_page_to_load
      puts "Messages have been visited."
    end

    def wait_messages_page_to_load
      while @session.all('.msg-conversations-container__conversations-list').count != 1
        puts "waiting messages to appear"
        sleep(0.2)
      end
    end

    def get_threads_links(threads_number)
      elements = get_the_right_number_of_elements(threads_number)
      get_names_and_thread_links(elements)
    end
    
    #When we get to the message page, the first thread in loaded very fast
    #but the other are a bit slower. So we wait until we have more threads
    #with a limit of 20 secondes.

    def get_the_right_number_of_elements(threads_number)
      time = 0
      elements = @session.all('.msg-conversation-listitem__link').first(threads_number)
      while elements.count < threads_number
        puts "Searching for messages ..."
        scroll_to(elements.last)
        sleep(1)
        #only 20 threads are loaded at the beginning
        elements = @session.all('.msg-conversation-listitem__link').first(threads_number)
        time = time + 1
        if (time > 20)
          break
        end
      end
      elements
    end

    def get_names_and_thread_links(elements)
      elements.each do |element|
        thread_link = element[:href]
        name = element.find('.msg-conversation-listitem__participant-names').text
        hash = { :name => name, :thread_link => thread_link }
        @names_and_thread_links.push(hash)
      end
    end

    def display_names_and_thread_links
      @names_and_thread_links.each do |element|
        puts element[:name] + ' : ' + element[:thread_link]
      end
    end

    def scroll_to(element)
      script = <<-JS
        arguments[0].scrollIntoView(true);
      JS

      @session.driver.browser.execute_script(script, element.native)
    end

  end
end
