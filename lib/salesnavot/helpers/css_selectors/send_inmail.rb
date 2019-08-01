module CssSelectors
    # All css selectors used in Salesnavot::SendInmail Class
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
	end
end