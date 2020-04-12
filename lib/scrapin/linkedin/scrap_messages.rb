require 'scrapin/scrap_messages.rb'
module ScrapIn
  module LinkedIn
    # Class which yield messages and direction in sales conversation
    class ScrapMessages
      include Tools
      include ScrapIn::ScrapMessages
      include CssSelectors::LinkedIn::ScrapMessages
      def sender(message)
        message.find(sender_css_container)[:class].include?(sender_css) ? :incoming : :outgoing
      end
    end
  end
end
