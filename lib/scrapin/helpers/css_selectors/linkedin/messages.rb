module CssSelectors
  module LinkedIn
    # All css selectors used in ScrapIn::LinkedIn::Messages Class
    module Messages
      def message_number_css(count)
        ".msg-s-message-list li:nth-child(#{count + 2}) .msg-s-event-listitem"
      end

      def unknown_css
        '.button-primary-small'
      end

      def messages_list_css
        '.msg-s-event-listitem__message-bubble'
      end

      def message_content_css
        '.msg-s-event-listitem__body'
      end

      def message_direction_css
        '.msg-s-event-listitem--other'
      end

      def messages_thread_css
        '.msg-s-message-list-container'
      end

      def same_messages_list_css
        '.msg-s-event-listitem'
      end

      def lead_name_css
        '.msg-entity-lockup__entity-title'
      end
    end
  end
end
