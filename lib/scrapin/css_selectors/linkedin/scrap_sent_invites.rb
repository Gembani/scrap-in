module CssSelectors
  # All css selectors used in ScrapIn::SentInvites Class
  module LinkedIn
    module ScrapSentInvites
      def invitation_list_css
        '[data-sdui-screen$="InvitationSentWithType"]'
      end

      def invitation_css
        "#{invitation_list_css} [role=\"listitem\"]"
      end

      # The first paragraph of an invitation is the lead's name
      def lead_name_css
        'p'
      end

      def lead_link_css
        'a[href*="/in/"]'
      end
    end
  end
end
