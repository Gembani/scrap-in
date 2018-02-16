module Salesnavot
  class Messages
    def initialize(session, thread_link)
      @session = session
      @thread_link = thread_link

      @all_messages = []
    end

    def execute(number_of_messages = 10)
      @number_of_messages = number_of_messages
      visit_thread_link
      messages_blocks = get_messages_blocks
      parse(messages_blocks)
    end

    def visit_thread_link
      @session.visit(@thread_link)
      wait_messages_to_appear
      puts "Messages have been visited."
    end

    def wait_messages_to_appear
      while @session.all('.msg-s-message-list-container').count != 1
        puts "waiting messages to appear"
        sleep(0.2)
      end
    end

    def get_messages_blocks
      messages_blocks = @session.all('.msg-s-event-listitem').last(@number_of_messages)
      while messages_blocks.count < @number_of_messages
        puts "Searching for more messages ..."
        #only 20 messages are loaded at the beginning
        scroll_to(messages_blocks.first)
        sleep(1)
        tmp = messages_blocks.count
        messages_blocks = @session.all('.msg-s-event-listitem').last(@number_of_messages)
        if tmp == messages_blocks.count
          break
        end
      end
      messages_blocks
    end

    def parse(messages_blocks)
      messages_blocks.each do |block|
        message = block.find("p.msg-s-event-listitem__body").text

        if block[:class].include?("msg-s-event-listitem--other")
          hash = { :direction => :incoming, :message => message }
        else
          hash = { :direction => :outcoming, :message => message }
        end

        @all_messages.push(hash)
      end
    end

    def display_messages
      name = @session.all(".msg-entity-lockup__entity-title").first.text
      @all_messages.each do |message|
        if message[:direction] == :incoming
          puts name + " -> " + message[:message]
        else
          puts  "You -> " + message[:message]
        end
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
