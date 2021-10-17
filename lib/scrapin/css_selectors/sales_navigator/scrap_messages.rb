module CssSelectors
  module SalesNavigator
    # All css selectors used in ScrapIn::SalesNavigator::Messages Class
    module ScrapMessages
      def messages_css
        '.flex.flex-column.flex-grow-1.flex-shrink-zero.justify-flex-end'
      end

      def message_thread_css
        '.flex.flex-column.flex-grow-1.flex-shrink-zero.justify-flex-end > ul.list-style-none'
      end

      def message_thread_elements_css
        'li'
      end

      def loaded_messages_css
        '.flex.flex-column.flex-grow-1.flex-shrink-zero.justify-flex-end > ul.list-style-none li'
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
