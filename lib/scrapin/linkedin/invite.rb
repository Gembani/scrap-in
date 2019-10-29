module ScrapIn
  module LinkedIn
    class Invite
      include ScrapIn::Tools
      include CssSelectors::LinkedIn::Invite
      def initialize(session, _lead_url)
        @session = session
      end

      def execute(lead_url, note = '', send = true)
        visit_lead_url(lead_url)
        return false unless search_for_connect_button

        search_for_add_a_note_button(note)
        sending_invitation_message(send)
        confirmation_invite_is_sent if send
        true
      end
      
      def visit_lead_url(lead_url)
        @session.visit(lead_url)
        puts 'Lead profile has been visited'
      end

      def search_for_connect_button
        buttons = @session.all(buttons_css)
        puts 'Search for Connect button'
        connect_worked = click_button(buttons, 'Connect')
        unless connect_worked
          puts 'Connect not found. Search for More… button'
          return false unless click_button(buttons, 'More…')

          puts 'Search for Connect button'
          buttons = @session.all(connect_in_more_button_css, visible: false)
          connect_worked = click_button(buttons, 'Connect')
        end
        connect_worked
      end

      def search_for_add_a_note_button(note)
        puts 'Search for add_a_note button'
        buttons_popup = @session.all(buttons_css)
        return false unless click_button(buttons_popup, 'Add a note')

        input_note_area = check_and_find(@session, note_area_css)
        input_note_area.send_keys(note)
      end
      
      def sending_invitation_message(send)
        puts 'Sending invitation message'
        new_buttons_popup = @session.all(buttons_css)
        click_button(new_buttons_popup, 'Send invitation') if send
      end

      def confirmation_invite_is_sent
        return true if check_and_find(@session, 'span', text: confirmation_text)
        false
      end

      private

      def click_button(buttons_array, button_name)
        buttons_array.each do |button|
          next unless button.text.include?(button_name)

          button.click
          puts "Clicked on #{button_name}"
          return true
        end
        false
      end
    end
  end
end
