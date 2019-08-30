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
				buttons = @session.all('.artdeco-button')
				puts 'Search for Connect button'
				connect_worked = click_connect(buttons)
				# byebug
				unless connect_worked
					puts 'Connect not found. Search for More… button'
					click_more(buttons)
					puts 'Search for Connect button'
					byebug
					new_buttons = @session.all('.artdeco-button')
					click_connect(new_buttons)
				end
				puts 'Search for Send now button'
				click_send_now(new_buttons)
				true
			end
			
			def click_connect(buttons)
				buttons.each do |button|
					if button.text == 'Connect'
						button.click
						puts 'Clicked on Connect'
						return true
					end
				end
				return false
			end
	
			def click_more(buttons)
				buttons.each do |button|
					if button.text == 'More…'
						button.click
						puts 'Clicked on More…'
						return true
					end
				end
				return false
			end

			def click_send_now(buttons)
				buttons.each do |button|
					if button.text == 'Send now'
						button.click
						puts 'Clicked on Send now'
						return true
					end
				end
				return false
			end
			# def execute(lead_url)
			# 	visit_lead_url(lead_url)
			# 	degree = check_and_find_all(@session, degree_css).first.text
			# 	puts "#{degree} degree"
			# 	# byebug
			# 	if (degree == '2nd')
			# 		check_and_find_all(@session, connect_button_css).first.click
			# 		puts 'Click on Connect...'
			# 	elsif (degree == '3rd')
			# 		check_and_find(@session, more_button_css).click
			# 		check_and_find(@session, connect_in_more_button_css).click
			# 	end
			# 	@session.all('.artdeco-button')[4].click
			# 	# check_and_find_all(send_now_button_css)[4].click
			# 	return false unless check_and_find(@session, confirm_invite_css)
			# 	true
			# end

			def visit_lead_url(lead_url)
				@session.visit(lead_url)
				puts 'Lead profile has been visited'
			end
		end
	end
end