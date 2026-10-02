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

      def profile_top_card_css
        '[componentkey$="Topcard"]'
      end

      # Opens the messaging overlay from a profile, used for a first message to a connection
      def profile_message_button_css
        'a[aria-label^="Message"], button[aria-label^="Message"]'
      end

      def thread_path
        '/messaging/thread/'
      end
    end
  end
end
