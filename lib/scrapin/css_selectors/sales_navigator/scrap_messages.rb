module CssSelectors
  module SalesNavigator
    # All css selectors used in ScrapIn::SalesNavigator::Messages Class
    module ScrapMessages
      def sales_messages_css
        '.thread-container'
      end

      def message_thread_css
        '.infinite-scroll-container'
      end

      def message_thread_elements_css
        'li'
      end

      def sales_loaded_messages_css
        '.thread-container li'
      end

      def content_css
        'p'
      end

      def sender_css
        'span'
      end

      def lead_name_css
        '.conversation-insights__section.pt4 .artdeco-entity-lockup__title > span:first-child'
      end
    end
  end
end
