module CssSelectors
  module LinkedIn
    # All css selectors used in ScrapIn::SendMessage Class
    module SendMessage
      def message_field_css
        '.msg-form__contenteditable'
      end

      def send_button_css
        '.msg-form__send-button'
      end

      def messages_css
        'p.msg-s-event-listitem__body'
      end
    end
  end
end
