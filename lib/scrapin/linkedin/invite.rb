module ScrapIn
	module LinkedIn
		class Invite
			include ScrapIn::Tools
			include CssSelectors::LinkedIn::Invite
			def initialize(session, lead_url)
        @session = session
			end
			
			def execute(lead_url)
				visit_lead_url(lead_url)
				deg = check_and_find_all(@session, degree_css).first.text
				puts "#{deg} degree"
				if (deg == '2nd')
					check_and_find_all(@session, connect_button_css).first.click
					puts 'Click on Connect...'
				elsif (deg == '3rd')
					check_and_find(@session, more_button_css).click
					check_and_find(@session, connect_in_more_button_css).click
				end
				byebug
				check_and_find_all(send_now_button).first.click
				return false unless check_and_find(@session, confirm_invite_css)
				true
			end

			def visit_lead_url(lead_url)
				@session.visit(lead_url)
				puts 'Lead profile has been visited'
			end
		end
	end
end