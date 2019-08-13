module CssSelectors
  # All css selectors used in ScrapIn::Friend Class
  module Friends
    def friend_name_css
      '.mn-connection-card__name'
    end

    def time_ago_css
      '.time-ago'
    end

    def link_css
      '.mn-connection-card__details a'
    end

    def nth_friend_css(count)
      "section.mn-connections > ul >  li:nth-child(#{count + 1})"
    end
  end
end
