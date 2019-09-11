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

      def message_button_css
        'button.pv-s-profile-actions--message'
      end

      def sent_message_css
        '.msg-s-event-listitem p'
      end
    end
  end
end