module CssSelectors
  module LinkedIn
    module ScrapMessages
      # All css selectors used in ScrapIn::LinkedIn::Messages Class
      def messages_css
        '.msg-s-message-list-container'
      end

      def message_thread_css
        '.msg-s-message-list'
      end

      def message_thread_elements_css
        'li'
      end

      def loaded_messages_css
        '.msg-s-message-list-container li'
      end

      def content_css
        'p'
      end

      def sender_css_container
        '.msg-s-event-listitem'
      end

      def sender_css
        'msg-s-event-listitem--other'
      end

      def lead_name_css
        '.msg-thread__link-to-profile h2'
      end
    end
  end
end
