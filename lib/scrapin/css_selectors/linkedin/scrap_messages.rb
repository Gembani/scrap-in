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

      # Plain 'li' also matches the emoji reaction menus inside each message
      def message_thread_elements_css
        'li.msg-s-message-list__event'
      end

      def loaded_messages_css
        '.msg-s-message-list-container li.msg-s-message-list__event'
      end

      def content_css
        'p.msg-s-event-listitem__body'
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
