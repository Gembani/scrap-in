module ScrapIn
  # Go to friend list, and get their names
  # and when you connected with them
  module LinkedIn
    class ScrapFriends
      include Tools
      include CssSelectors::LinkedIn::ScrapFriends
      attr_reader :error
      def initialize(session)
        @session = session
        @error = ''
      end

      def execute(num_times = 40)
        return unless visit_target_page
        count = 0
        num_times.times do
          search_for_name_and_time_ago(count) do |name, time_ago, link|
            yield name, time_ago, link
          end
          count += 1
        end
      end

      def search_for_name_and_time_ago(count)
        friend = get_next_friend(count)
        if friend && @session.has_selector?(friend_name_css) &&
            @session.has_selector?(time_ago_css) && @session.has_selector?(link_css)
          name = friend.find(friend_name_css).text
          link = friend.find(link_css)[:href].chomp("/")
          time_ago = friend.find(time_ago_css).text
          yield name, time_ago, link
        end
      end

      def visit_target_page
        @session.visit(connections_url)
        unless @session.has_selector?(nth_friend_css(0))
          @error = "No friend found (no css element: #{nth_friend_css(0)})"
          return false
        end
        true
      end

      def get_next_friend(count)
        return nil unless @session.has_selector?(nth_friend_css(count))
        friend = @session.find(nth_friend_css(count))
        scroll_to(friend)
        friend
      end

      def connections_url
        'https://www.linkedin.com/mynetwork/invite-connect/connections/'
      end
    end
  end
end
