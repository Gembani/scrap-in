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

        num_times.times do |count|
          friend = get_next_friend(count)
          break unless friend

          yield name(friend), time_ago(friend), link(friend)
        end
        true
      end

      def visit_target_page
        @session.visit(@connection_url)
        return false unless wait_friends_to_appear

        puts 'Connections have been visited.'
        true
      end

      def wait_friends_to_appear
        puts 'waiting connections to appear'
        try_until_true(3) do
          @session.has_selector?(friend_card_css)
        end
      end

      def get_next_friend(count)
        friends = @session.all(friend_card_css, wait: 0)
        friends = load_more_items(friend_card_css, friends.size) if count >= friends.size
        friend = friends[count]
        scroll_to(friend) if friend
        friend
      end

      def name(friend)
        check_and_find(friend, friend_name_css).text
      end

      # "Connected on October 2, 2026" -> "October 2, 2026"
      def time_ago(friend)
        check_and_find(friend, 'p', text: connected_on_regex).text.sub(connected_on_regex, '')
      end

      def link(friend)
        check_and_find_first(friend, link_css)[:href].chomp('/')
      end
    end
  end
end
