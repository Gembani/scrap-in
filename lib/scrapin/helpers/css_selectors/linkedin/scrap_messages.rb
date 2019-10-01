module CssSelectors
  module LinkedIn
    # All css selectors used in ScrapIn::LinkedIn::Messages Class
    module ScrapMessages
      def message_content_css
        '.msg-s-event-listitem__body'
      end

      def messages_thread_css
        '.msg-s-message-list-container'
      end

      def sender_css
        'msg-s-event-listitem--other'
      end

      def all_messages_css
        '.msg-s-message-list li .msg-s-event-listitem'
      end
    end
  end
end
