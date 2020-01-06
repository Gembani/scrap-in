module CssSelectors
  module LinkedIn
    module Invite
      def connect_buttons_css
        'button[aria-label^="Connect"]'
      end

      def css_more_button
        'artdeco-dropdown > artdeco-dropdown-trigger > button'
      end

      def connect_in_more_button_css
        '[type^="connect-icon"]'
      end

      def add_a_note_button_css
        'button.artdeco-button--secondary[aria-label="Add a note"]'
      end

      def note_area_css
        '.send-invite__custom-message'
      end

      def send_invitation_button_css 
        'button[aria-label="Send invitation"]'
        
      end

      def confirmation_text
        'Your invitation to'
      end

      def more_dropdown_css
        '.pv-s-profile-actions__overflow-dropdown'
      end
    end
  end
end
