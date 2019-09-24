module CssSelectors
	module LinkedIn
		module Threads
			def threads_block_count_css(count)
				".msg-conversations-container__conversations-list li:nth-child(#{count + 2})"
			end

			 def threads_block_css
				'.msg-conversations-container__conversations-list li'
			end

			 def one_thread_css
				'.msg-conversation-listitem__participant-names'
			end

			 def href_css
				'a'
			end
		end
	end
end 