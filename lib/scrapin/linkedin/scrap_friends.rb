module ScrapIn
  module LinkedIn
    # Go to friend list, and get their names
    # and when you connected with them
    class ScrapFriends
      include Tools
      include CssSelectors::LinkedIn::ScrapFriends
      def initialize(session)
        @session = session
        @connection_url = 'https://www.linkedin.com/mynetwork/invite-connect/connections/'
      end

      def execute(num_times = 40)
        return false unless visit_target_page

        count = 0
        num_times.times do
          search_for_name_and_time_ago(count) do |name, time_ago, link|
            yield name, time_ago, link
          end
          count += 1
        end
        true
      end

      def search_for_name_and_time_ago(count)
        friend = get_next_friend(count)
        if friend && @session.has_selector?(friend_name_css) &&
           @session.has_selector?(time_ago_css) && @session.has_selector?(link_css)
          name = check_and_find(friend, friend_name_css).text
          link = check_and_find(friend, link_css)[:href].chomp('/')
          time_ago = check_and_find(friend, time_ago_css).text
          yield name, time_ago, link
        end
      end

      def visit_target_page
        @session.visit(@connection_url)
        return false unless wait_messages_to_appear

        puts 'Messages have been visited.'
        true
      end
      
      def wait_messages_to_appear
        puts 'waiting messages to appear'
        messages_appear = try_until_true(500) do
          @session.has_selector?(nth_friend_css(0))
        end
        messages_appear
      end

      def get_next_friend(count)
        return nil unless @session.has_selector?(nth_friend_css(count))

        friend = check_and_find(@session, nth_friend_css(count))
        scroll_to(friend)
        friend
      end
    end
  end
end
