module Salesnavot
  class Friends
    def initialize(session)
      @session = session
    end

    def scroll_to(element)
      script = <<-JS
        arguments[0].scrollIntoView(true);
      JS
      @session.driver.browser.execute_script(script, element.native)
    end

    def nth_friend_css(count)
      "section.mn-connections > ul >  li:nth-child(#{count + 1})"
    end

    def get_next_friend(count)
      return nil unless @session.has_selector?(nth_friend_css(count))
      friend = @session.find(nth_friend_css(count))
      scroll_to(friend)
      friend
    end

    def friend_name_css
      '.mn-connection-card__name'
    end

    def time_ago_css
      '.time-ago'
    end

    def execute(num_times = 40)
      init_list
      count = 0
      num_times.times do
        puts 'Loop'
        friend = get_next_friend(count)
        puts 'before condition'
        if friend && @session.has_selector?(friend_name_css) &&
            @session.has_selector?(time_ago_css)
          puts 'condition ok'
          name = friend.find(friend_name_css).text
          time_ago = friend.find(time_ago_css).text
          yield time_ago, name
        end
        count += 1
      end
      puts 'End execute'
    end

    def init_list
      puts 'Before Visit'
      @session.visit('https://www.linkedin.com/mynetwork/invite-connect/connections/')
      puts 'After Visit'
      unless @session.has_selector?(nth_friend_css(0))
        puts 'Error a'
        @error = "No friend found (no css element: #{nth_friend_css(0)})"
        return false
      end
      true
    end
  end
end
