module CssSelectors
  # All css selectors used in Salesnavot::Invite Class
  module SalesNavMessages
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

    def police_css
      'aria-label'
    end

    def content_css
      'p'
    end

    def sender_css
      'span'
    end
    # section 'thread-container'
    # class="flex flex-column full-height overflow-y-hidden ember-view"
    # class='infinite-scroll-container flex flex-column full-height overflow-y-auto '
    # ul class="list-style-none"
    # last('li')
    # class="relative" 
    # if span.content == "You" : outgoing else incoming
    # p.content == message
  end
end