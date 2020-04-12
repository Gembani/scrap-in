require 'scrapin/scrap_messages.rb'
module ScrapIn
  module SalesNavigator
    # Class which yield messages and direction in sales conversation
    class ScrapMessages
      include Tools
      include ScrapIn::ScrapMessages
      include CssSelectors::SalesNavigator::ScrapMessages

      def sender(message)
        sender = check_and_find_first(message, sender_css, wait: 2, visible: false)['innerHTML'].strip
        sender == 'You' ? :outgoing : :incoming
      end
    
    end
  end
end
