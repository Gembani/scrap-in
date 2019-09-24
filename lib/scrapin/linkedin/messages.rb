module ScrapIn
  module LinkedIn
    # Class which yield messages and direction in linkedin
    class Messages
      include Tools
      include CssSelectors::LinkedIn::Messages
      def initialize(session, thread_link)
        @session = session
        @thread_link = thread_link
      end
      
      def execute(number_of_messages = 20)
        return false unless number_of_messages.positive?

        return false unless visit_thread_link
        loaded_messages = load(number_of_messages)
        count = loaded_messages - 1
        loaded_messages.times.each do
          message = @session.all('.msg-s-message-list li .msg-s-event-listitem')
          content = check_and_find(message[count], '.msg-s-event-listitem__body').text
          direction = message.include?('msg-s-event-listitem--other') ? :incoming : :outgoing
          count -= 1
          yield content, direction
        end
      end
      # def css(count)
      #   ".msg-s-message-list li:nth-child(#{count + 2}) .msg-s-event-listitem"
      # end
      
      # def can_send_greeting_message
      #   number_of_messages = 0
      #   execute(2) do |_message, _direction|
      #     number_of_messages += 1
      #   end
      #   number_of_messages == 1
      # end

      # def execute(number_of_messages = 20)
      #   visit_thread_link
      #   count = 0
        
      #   number_of_messages.times.each do
      #     item = @session.all(message_number_css(0)).first
      #     scroll_to(item)
      #     sleep(1)
      #   end
        
      #   number_of_messages.times.each do
      #     item = @session.all(message_number_css(count)).last
      #     count += 1
      #     if item.nil?
      #       count = 0
      #       break
      #     else
      #       next unless item.all(messages_list_css).count == 1
      #       message = item.find(message_content_css).text
      #       direction = item[:class].include?(message_direction_css) ? :incoming : :outgoing
      #     end
      #     yield message, direction
      #   end
      #   sleep(0.5)
      # end
      
      def visit_thread_link
        @session.visit(@thread_link)
        return false unless wait_messages_to_appear
        puts 'Messages have been visited.'
        true
      end
      
      def wait_messages_to_appear
        puts 'waiting messages to appear'
        messages_appear = check_until(500) do
          @session.all(messages_thread_css).count > 0
        end
        messages_appear
      end

      def load(number_of_messages)
        loaded_messages = count_loaded_messages
        while loaded_messages < number_of_messages && loaded_messages > 0
          first_message = check_and_find_first(@session, '.msg-s-message-list li .msg-s-event-listitem')
          check_until(500) do
            scroll_to(first_message)
          end
          return loaded_messages if loaded_messages == count_loaded_messages

          loaded_messages = count_loaded_messages
        end
        loaded_messages
      end

      def count_loaded_messages
        check_and_find_all(@session, '.msg-s-message-list li .msg-s-event-listitem').count
      end
      
      # def get_messages_blocks
      #   messages_blocks = @session.all(same_messages_list_css).last(@number_of_messages)
      #   while messages_blocks.count < @number_of_messages
      #     puts 'Searching for more messages ...'
      #     # only 20 messages are loaded at the beginning
      #     scroll_to(messages_blocks.first)
      #     sleep(1)
      #     tmp = messages_blocks.count
      #     messages_blocks = @session.all(same_messages_list_css).last(@number_of_messages)
      #     break if tmp == messages_blocks.count
      #   end
      #   messages_blocks
      # end
      
      # def parse(messages_blocks)
      #   messages_blocks.each do |block|
      #     next unless block.all(messages_list_css).count == 1
      #     message = block.find(message_content_css).text
      #     hash = if block[:class].include?(message_direction_css)
      #       { direction: :incoming, message: message }
      #     else
      #       { direction: :outgoing, message: message }
      #     end
          
      #     @all_messages.push(hash)
      #   end
      # end
      
      # def display_messages
      #   name = @session.all(lead_name_css).first.text
      #   @all_messages.each do |message|
      #     if message[:direction] == :incoming
      #       puts name + ' -> ' + message[:message]
      #     else
      #       puts 'You -> ' + message[:message]
      #     end
      #   end
      # end
    end
  end
end
