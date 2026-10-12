module CssSelectors
  module LinkedIn
    module ScrapThreads
      def threads_block_count_css(count)
        ".msg-conversations-container__conversations-list li:nth-child(#{count + 2})"
      end

      def threads_block_css
        '.msg-conversations-container__conversations-list'
      end

      def one_thread_css
        '.msg-conversation-listitem__participant-names'
      end

      def threads_list_css
        '.msg-conversation-listitem'
      end

      # The open conversation (the same selectors ScrapMessages reads it with)
      def pane_name_css
        '.msg-thread__link-to-profile h2'
      end

      def message_items_css
        '.msg-s-message-list-container li.msg-s-message-list__event'
      end

      def message_body_css
        'p.msg-s-event-listitem__body'
      end

      def message_sender_css
        '.msg-s-event-listitem'
      end

      def incoming_css
        'msg-s-event-listitem--other'
      end
    end
  end
end
