module ScrapIn
  # Goes to "Sent invitations" page, and scrap all leads that were invited
  module LinkedIn
    class ScrapSentInvites
      include Tools
      include CssSelectors::LinkedIn::ScrapSentInvites
      attr_reader :invited_leads
      def initialize(session)
        @session = session
        @invited_leads = []
      end

      def target_page
        'https://www.linkedin.com/mynetwork/invitation-manager/sent/'
      end

      def execute(num_times = 50)
        return unless init_list(target_page)

        num_times.times do |count|
          invitation = get_invitation(count)
          break unless invitation

          find_lead(invitation) { |url, name| yield url, name }
        end
      end

      def get_invitation(count)
        invitations = @session.all(invitation_css, wait: 0)
        invitations = load_more_items(invitation_css, invitations.size) if count >= invitations.size
        invitations[count]
      end

      def find_lead(item)
        scroll_to(item)
        name = check_and_find_first(item, lead_name_css).text
        url = check_and_find_first(item, lead_link_css)[:href]
        return if name.empty?

        @invited_leads.push name
        yield url, name
      end

      def init_list(link)
        @session.visit(link)
        return false unless @session.has_selector?(invitation_css)

        true
      end
    end
  end
end
