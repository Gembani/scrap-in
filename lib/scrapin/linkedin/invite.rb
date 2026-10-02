module ScrapIn
  module LinkedIn
    class Invite
      include ScrapIn::Tools
      include CssSelectors::LinkedIn::Invite
      def initialize(session)
        @session = session
      end

      # Free accounts only get a few personalized invitations a month, an empty note sends without one.
      # With send = false the invitation is prepared then dismissed.
      def execute(lead_url, note = '', send = true)
        visit_lead_url(lead_url)
        return true if pending?

        click_connect_button
        modal = invite_modal
        add_a_note(modal, note) unless note.to_s.empty?
        return dismiss(modal) unless send

        sending_invitation_message(modal, note)
        confirmation_invite_is_sent
      end

      def visit_lead_url(lead_url)
        @session.visit(lead_url)
        puts 'Lead profile has been visited'
      end

      def pending?
        top_card.has_selector?(pending_css, wait: 1)
      end

      def click_connect_button
        puts 'Search for Connect button'
        card = top_card
        if card.has_selector?(connect_button_css, wait: 1)
          card.find(connect_button_css).click
        else
          check_and_find(card, 'button', text: more_button_text).click
          check_and_find(@session, menu_item_css, text: /\A#{connect_text}\z/).click
        end
      end

      def invite_modal
        host = check_and_find(@session, modal_host_css, visible: :all)
        check_and_find(host.shadow_root, modal_css, wait: 5)
      end

      def add_a_note(modal, note)
        puts 'Adding a note'
        find_and_click(modal, add_a_note_button_css)
        check_and_find(modal, note_area_css).send_keys(note)
      end

      def sending_invitation_message(modal, note)
        puts 'Sending invitation message'
        find_and_click(modal, note.to_s.empty? ? send_without_note_button_css : send_invitation_button_css)
      end

      def dismiss(modal)
        find_and_click(modal, dismiss_button_css)
        true
      end

      def confirmation_invite_is_sent
        try_until_true(5, 1) { pending? }
      end

      private

      def top_card
        check_and_find(@session, top_card_css, wait: 10)
      end
    end
  end
end
