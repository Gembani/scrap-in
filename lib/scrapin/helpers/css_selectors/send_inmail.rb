module CssSelectors
    # All css selectors used in ScrapIn::SendInmail Class
	module SendInmail
		def degree_css
			'.profile-topcard-person-entity__content span'
		end

		def degree_text
			"1st"
		end

		def subject_placeholder
			'Subject (required)'
		end

		def message_placeholder
			'Type your message here…'	
		end

		def message_container
			'article'
		end

		def message_button_css
			'button'
		end

		def message_button_text
			'Message'
		end

		def send_button_text
			'Send'
		end
	end
end