module ScrapIn
  module LinkedIn
    class Invite
      include ScrapIn::Tools
      include CssSelectors::LinkedIn::Invite
      def initialize(session)
        @session = session
      end

      def execute(lead_url, note = '', send = true)
        visit_lead_url(lead_url)
        return true if pending?
        click_connect_button
        add_a_note(note)
        sending_invitation_message(send)
        confirmation_invite_is_sent if send
        true
      end
      
      def visit_lead_url(lead_url)
        @session.visit(lead_url)
        puts 'Lead profile has been visited'
      end

      def pending?
        button = check_and_find(@session, css_more_button)
        button.click
        dropdown_item = check_and_find_first(@session, more_dropdown_css)
        is_pending = dropdown_item.text.split("\n").include?("Pending")
        button.click
        is_pending
      end

      def click_connect_button
        puts 'Search for Connect button'
        if @session.has_selector?(connect_buttons_css)
          button = @session.find(connect_buttons_css)
          button.click
        elsif @session.has_selector?(css_more_button)
          button = @session.find(css_more_button)
          button.click
          find_and_click(@session, connect_in_more_button_css)
        else  
          raise CssNotFound, "#{connect_buttons_css } || #{css_more_button}"
        end
      end

      def add_a_note(note)
        puts 'Search for add_a_note button'
        find_and_click(@session, add_a_note_button_css)
        input_note_area = check_and_find(@session, note_area_css)
        input_note_area.send_keys(note)
      end
      
      def sending_invitation_message(send)
        puts 'Sending invitation message'
        raise CssNotFound, send_invitation_button_css unless @session.has_selector?(send_invitation_button_css)
        @session.find(send_invitation_button_css).click if send
      end

      def confirmation_invite_is_sent
        @session.has_selector?( 'span', text: confirmation_text)
      end
    end
  end
end
