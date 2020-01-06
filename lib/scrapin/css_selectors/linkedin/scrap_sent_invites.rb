module CssSelectors
  # All css selectors used in ScrapIn::SentInvites Class
  module LinkedIn
    module ScrapSentInvites
      def nth_lead_css(count, invitation: true)
        if invitation
          ".mn-invitation-list li:nth-child(#{count + 1}) .invitation-card__title"
        else
          ".mn-invitation-list li:nth-child(#{count + 1})"
        end
      end

      def invitation_list_css
        '.mn-invitation-list'
      end

      def next_button_css
        'button[aria-label="Next"]'
      end
    end
  end
end
