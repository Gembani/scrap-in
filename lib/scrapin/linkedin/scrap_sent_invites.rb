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

      def find_lead(count)
        return unless @session.has_selector?(nth_lead_css(count), wait: 3)

        item = @session.find(nth_lead_css(count))
        scroll_to(item)
        
        name = item.text
        url = item.find(:xpath, '..')[:href]
        return if name.empty?

        @invited_leads.push name
        yield url, name
      end

      def execute(num_times = 50)
        return unless init_list(target_page)

        count = 0
        num_times.times.each do
          unless @session.has_selector?(
            nth_lead_css(count, invitation: false), wait: 10
          )
            count = 0
            break unless next_page
          end
          find_lead(count) { |url, name| yield url, name }
          count += 1
        end
      end

      def init_list(link)
        @session.visit(link)
        return false unless @session.has_selector?(invitation_list_css)

        true
      end
     
      def next_page
        url_pre_click = @session.current_url
        byebug
        find_and_click(@session, next_button_css)
        
        check_until(1000) do 
          url_pre_click != @session.current_url
        end
      end
    end
  end
end
