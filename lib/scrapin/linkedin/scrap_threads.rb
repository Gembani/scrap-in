module ScrapIn
  module LinkedIn
    # Opens the inbox's conversations, newest activity first, and yields each one's name, thread link and newest
    # message ([content, :incoming / :outgoing], nil when it can't be read with certainty). Scrolls the list to load
    # more as it goes. The block returns :stop to end the scan (e.g. once the caller already has what follows).
    class ScrapThreads
      include Tools
      include CssSelectors::LinkedIn::ScrapThreads
      def initialize(session)
        @session = session
      end

      def execute(num_times = 10)
        raise ArgumentError, 'Parameter should be positive' unless num_times.positive?

        visit_messages_link
        count = 0
        loaded = set_limit

        num_times.times.each do
          loaded = load_more(loaded) if count >= loaded
          if count >= loaded
            puts 'reach max open conversations'
            break
          end

          conversation = find_conversation(count)
          scroll_to(conversation)
          name = conversation.text
          conversation.click
          thread_link = @session.current_url
          count += 1
          break if yield(name, thread_link, last_message(name)) == :stop

          sleep(rand(1.5..3.0))
        end
        true
      end

      def visit_messages_link
        @session.visit('https://www.linkedin.com/messaging/')
        puts 'Messages have been visited.'
      end

      def find_conversation(count)
        threads_list_2 = check_and_find(@session, threads_block_count_css(count))
        check_and_find(threads_list_2, one_thread_css, wait: 5)
      end

      def set_limit
        threads_list = check_and_find(@session, threads_block_css)
        threads_list.all(threads_list_css, wait: 5).count
      end

      # The list loads more conversations when scrolled to its end
      def load_more(loaded)
        last = check_and_find(@session, threads_block_css).all(threads_list_css, wait: 5).last
        return loaded if last.nil?

        scroll_to(last)
        sleep(2)
        set_limit
      end

      # The newest message with a text body in the open conversation, once the pane shows that conversation
      def last_message(name)
        expected = name.to_s.split(',').first.to_s.strip
        return if expected.empty?
        return unless try_until_true(10, 0.3) { @session.has_selector?(pane_name_css, text: expected, wait: 0) }

        @session.all(message_items_css, wait: 2).reverse_each do |item|
          body = item.first(message_body_css, minimum: 0, wait: 0)
          next if body.nil?

          sender = item.first(message_sender_css, minimum: 0, wait: 0)
          return [body['innerHTML'], sender && sender[:class].to_s.include?(incoming_css) ? :incoming : :outgoing]
        end
        nil
      rescue Capybara::ElementNotFound, Selenium::WebDriver::Error::StaleElementReferenceError
        nil
      end
    end
  end
end
