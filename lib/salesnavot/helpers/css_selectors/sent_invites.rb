module CssSelectors
  # All css selectors used in Salesnavot::SentInvites Class
  module SentInvites
    def nth_lead_css(count, invitation: true)
      if invitation
        ".mn-invitation-list li:nth-child(#{count + 1}) .invitation-card__title"
      else
        ".mn-invitation-list li:nth-child(#{count + 1})"
      end
    end

    def pagination_selector
      'a.mn-invitation-pagination__control-btn'
    end

    def invitation_list_css
      '.mn-invitation-list'
    end

    def next_button_css
      'li-icon[aria-label="Next item"]'
    end
  end
end
