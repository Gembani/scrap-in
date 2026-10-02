require 'scrapin/scrap_messages.rb'
module ScrapIn
  module LinkedIn
    # Class which yield messages and direction in a conversation
    class ScrapMessages
      include Tools
      include ScrapIn::ScrapMessages
      include CssSelectors::LinkedIn::ScrapMessages
      # message_thread_elements_css only matches messages, there is no header to skip
      def first_message_index
        0
      end

      # Link previews, attachments... have no text body, they are skipped
      def message_content(message)
        content = message.first(content_css, minimum: 0)
        content && content['innerHTML']
      end

      def sender(message)
        message.find(sender_css_container)[:class].include?(sender_css) ? :incoming : :outgoing
      end
    end
  end
end
