module CssSelectors
  # All css selectors used in ScrapIn::Threads Class
  module SalesNavigator
    module ScrapThreads
      def threads_list_css
        '.infinite-scroller ul'
      end

      def threads_list_elements_css
        'li'
      end

      def loaded_threads_css
        '.list-style-none .conversation-list-item'  
      end

      def thread_name_css
        '.artdeco-entity-lockup__title'
      end

      def message_css
        '.thread-container li'
      end

      def lead_name_css
        '.inbox__right-rail-container > .conversation-insights__section .artdeco-entity-lockup__title > span:first-child'
      end
    end
  end
end
