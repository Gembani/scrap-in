module CssSelectors
  # All css selectors used in ScrapIn::Friend Class
  module LinkedIn
    module ScrapFriends
      # componentkey is "ConnectionCard_<page offset>-<profile slug>"
      def friend_card_css
        '[componentkey^="ConnectionCard_"]'
      end

      # The name is the first paragraph of the profile link, the headline is nested deeper
      def friend_name_css
        'a[href*="/in/"] > div > p'
      end

      def link_css
        'a[href*="/in/"]'
      end

      def connected_on_regex
        /\AConnected on\s*/
      end
    end
  end
end
