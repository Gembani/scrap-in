module Salesnavot
  class Messages
    include Tools
    def initialize(session, thread_link)
      @session = session
      @thread_link = thread_link
    end

    def css(count)
      ".msg-s-message-list li:nth-child(#{count + 2}) .msg-s-event-listitem"
    end

    def can_send_greeting_message
      number_of_messages = 0
      execute(2) do |_message, _direction|
        number_of_messages += 1
      end
      number_of_messages == 1
    end

    def send_greeting_message(msg)
      if can_send_greeting_message
        @session.fill_in('message', with: msg)
        @session.find('.button-primary-small').click
        true
      else
        false
      end
    end

    def execute(number_of_messages = 20)
      visit_thread_link
      count = 0

      number_of_messages.times.each do
        item = @session.all(css(0)).first
        scroll_to(item)
        sleep(1)
      end

      number_of_messages.times.each do
        item = @session.all(css(count)).last
        count += 1
        if item.nil?
          count = 0
          break
        else
          next unless item.all('.msg-s-event-listitem__message-bubble').count == 1
          message = item.find('.msg-s-event-listitem__body').text
          direction = item[:class].include?('msg-s-event-listitem--other') ? :incoming : :outgoing
        end
        yield message, direction
      end
      sleep(0.5)
    end

    # def execute(number_of_messages = 10)
    #   @number_of_messages = number_of_messages
    #   visit_thread_link
    #   messages_blocks = get_messages_blocks
    #   parse(messages_blocks)
    # end

    def visit_thread_link
      @session.visit(@thread_link)
      wait_messages_to_appear
      puts 'Messages have been visited.'
    end

    def wait_messages_to_appear
      while @session.all('.msg-s-message-list-container').count != 1
        puts 'waiting messages to appear'
        sleep(0.2)
      end
    end

    def get_messages_blocks
      messages_blocks = @session.all('.msg-s-event-listitem').last(@number_of_messages)
      while messages_blocks.count < @number_of_messages
        puts 'Searching for more messages ...'
        # only 20 messages are loaded at the beginning
        scroll_to(messages_blocks.first)
        sleep(1)
        tmp = messages_blocks.count
        messages_blocks = @session.all('.msg-s-event-listitem').last(@number_of_messages)
        break if tmp == messages_blocks.count
      end
      messages_blocks
    end

    def parse(messages_blocks)
      messages_blocks.each do |block|
        next unless block.all('.msg-s-event-listitem__message-bubble').count == 1
        message = block.find('.msg-s-event-listitem__body').text
        hash = if block[:class].include?('msg-s-event-listitem--other')
                 { direction: :incoming, message: message }
               else
                 { direction: :outgoing, message: message }
               end

        @all_messages.push(hash)
      end
    end

    def display_messages
      name = @session.all('.msg-entity-lockup__entity-title').first.text
      @all_messages.each do |message|
        if message[:direction] == :incoming
          puts name + ' -> ' + message[:message]
        else
          puts 'You -> ' + message[:message]
        end
      end
    end
  end
end
