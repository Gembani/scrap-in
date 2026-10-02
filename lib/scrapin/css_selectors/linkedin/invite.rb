module CssSelectors
  module LinkedIn
    module Invite
      def top_card_css
        '[componentkey$="Topcard"]'
      end

      def connect_button_css
        'a[aria-label^="Invite"][aria-label$="to connect"]'
      end

      def more_button_text
        'More'
      end

      def menu_item_css
        '[role="menu"] [role="menuitem"]'
      end

      def connect_text
        'Connect'
      end

      def pending_css
        '[aria-label^="Pending"]'
      end

      # The invitation modal is rendered inside this element's shadow root
      def modal_host_css
        '#interop-outlet'
      end

      def modal_css
        '[role="dialog"]'
      end

      def send_without_note_button_css
        'button[aria-label="Send without a note"]'
      end

      def add_a_note_button_css
        'button[aria-label="Add a note"]'
      end

      def note_area_css
        'textarea#custom-message'
      end

      def send_invitation_button_css
        'button[aria-label="Send invitation"]'
      end

      def dismiss_button_css
        'button[aria-label="Dismiss"]'
      end

      # The connection degree line of the top card, "· 1st" means we are already connected
      def degree_regex
        /\A·\s*(1st|2nd|3rd)/
      end

      # Shown in the invitation modal instead of the send buttons once the weekly quota is used
      def weekly_limit_regex
        /weekly invitation limit|reached the limit/i
      end
    end
  end
end
