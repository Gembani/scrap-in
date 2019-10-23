module ScrapIn
  module LinkedIn
    # Goes to "Sent invitations" page, and scrap all leads that were invited
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

      def find_lead_name(count)
        return false unless @session.has_selector?(nth_lead_css(count), wait: 3)

        item = check_and_find(@session, nth_lead_css(count))
        # item = @session.find(nth_lead_css(count))
        scroll_to(item)
        name = item.text
        return false if name.empty?
        
        @invited_leads.push name
        yield name
        true
      end
      
      def execute(num_times = 50)
        return false unless init_list(target_page)
        
        count = 0
        num_times.times.each do
          unless @session.has_selector?(
            nth_lead_css(count, invitation: false), wait: 10
          )
            count = 0
            break unless next_page
          end
          find_lead_name(count) { |name| yield name }
          count += 1
        end
        true
      end

      def init_list(link)
        @session.visit(link)
        return false unless @session.has_selector?(invitation_list_css)

        true
      end
     
      def next_page
        url_pre_click = @session.current_url
        find_and_click(@session, next_button_css) 

        check_until(1000) do 
          url_pre_click != @session.current_url
        end
      end
    end
  end
end
