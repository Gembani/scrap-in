module ScrapIn
	module LinkedIn
		class Invite
			include ScrapIn::Tools
			include CssSelectors::LinkedIn::Invite
			def initialize(session, lead_url)
        @session = session
			end
			
			def execute(lead_url, note = '')
				visit_lead_url(lead_url)
				buttons = check_and_find_all(@session, buttons_css)
				puts 'Search for Connect button'
				connect_worked = click_button(buttons, 'Connect')
				unless connect_worked
					puts 'Connect not found. Search for More… button'
					click_button(buttons, 'More…')
					puts 'Search for Connect button'
					check_and_find_all(@session, connect_in_more_button_css, visible: false)[3].click
				end
				puts 'Search for Send now button'
				buttons_popup = check_and_find_all(@session, buttons_css)
				if note.empty?
					click_button(buttons_popup, 'Send now')
				else
					click_button(buttons_popup, 'Add a note')
					input_note_area = check_and_find(@session, note_area_css)
					input_note_area.send_keys(note)
					puts 'Sending invitation message'
					new_buttons_popup = check_and_find_all(@session, buttons_css)
					click_button(new_buttons_popup, 'Send invitation')
					puts 'Message sent'
				end
				return true if check_and_find(@session, 'span', text: confirmation_text)
				false
			end
			
			def click_button(buttons_array, button_name)
				buttons_array.each do |button|
					if button.text == button_name
						button.click
						puts "Clicked on #{button_name}"
						return true
					end
				end
				return false
			end

			def visit_lead_url(lead_url)
				@session.visit(lead_url)
				puts 'Lead profile has been visited'
			end
		end
	end
end