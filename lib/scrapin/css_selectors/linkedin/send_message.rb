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
        'a[href*="/messaging/compose/"][href*="recipient="], a[aria-label^="Message"], button[aria-label^="Message"]'
      end

      # Input/preview/completion markers observed during supervised draft validation.
      # Native-player acknowledgement was also observed on one approved send.
      # Error/processing variants and filename links still need live validation.
      def messaging_shadow_host_css
        '#interop-outlet'
      end

      def video_input_css
        'input[type="file"][accept*=".mp4"]'
      end

      def attachment_preview_css
        '.msg-form__attachment-preview'
      end

      def attachment_ready_css
        '[data-test-msg-cross-pillar-uploaded-attachments-list__attached]'
      end

      def attachment_name_css
        '[data-test-msg-cross-pillar-uploaded-attachments-list-presenter__attachment-name]'
      end

      def event_identity_css
        '.msg-s-event-listitem[data-event-urn]'
      end

      def attachment_busy_css
        'progress, [role="progressbar"], [aria-busy="true"], .msg-attachment-preview--uploading, .msg-attachment-preview--processing'
      end

      def attachment_error_css
        '[role="alert"], .msg-attachment-preview--error'
      end

      def conversation_xpath
        'ancestor::*[contains(concat(" ", normalize-space(@class), " "), " msg-thread ") or contains(concat(" ", normalize-space(@class), " "), " msg-overlay-conversation-bubble ") or contains(concat(" ", normalize-space(@class), " "), " scaffold-layout__detail ")][1]'
      end

      def message_events_css
        'li.msg-s-message-list__event'
      end

      def outgoing_event_css
        '.msg-s-event-listitem:not(.msg-s-event-listitem--other)'
      end

      def sent_video_css
        '.msg-s-event-listitem__message-bubble video[src]'
      end

      def sent_indicator_css
        '[data-test-msg-cross-pillar-message-sending-indicator-presenter__sending-indicator--sent]'
      end

      def sent_container_xpath
        'ancestor::*[contains(concat(" ", normalize-space(@class), " "), " msg-s-event-with-indicator ")][1]'
      end

      def sent_attachment_css
        'a.msg-s-event-listitem__attachment, .msg-s-event-listitem__attachment a'
      end

      def thread_path
        '/messaging/thread/'
      end
    end
  end
end
