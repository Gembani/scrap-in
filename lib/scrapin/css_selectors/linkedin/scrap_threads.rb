module CssSelectors
	module LinkedIn
		module ScrapThreads
			def threads_block_count_css(count)
				".msg-conversations-container__conversations-list li:nth-child(#{count + 2})"
			end

			 def threads_block_css
				'.msg-conversations-container__conversations-list'
			end

			 def one_thread_css
				'.msg-conversation-listitem__participant-names'
			end

			def threads_list_css
				'.msg-conversation-listitem'
			end
		end
	end
end 