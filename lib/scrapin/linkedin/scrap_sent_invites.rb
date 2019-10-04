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

      def find_lead_name(count)
        return unless @session.has_selector?(nth_lead_css(count), wait: 3)

        item = @session.find(nth_lead_css(count))
        scroll_to(item)
        name = item.text
        return if name.empty?

        @invited_leads.push name
        yield name
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
          find_lead_name(count) { |name| yield name }
          count += 1
        end
      end

      def init_list(link)
        @session.visit(link)
        return false unless @session.has_selector?(invitation_list_css)

        true
      end

      def find_next_button
        pagination_buttons = @session.all(pagination_selector)
        pagination_buttons.each do |button|
          next unless button.has_selector?(next_button_css, wait: 1)

          return button
        end
        nil
      end

      def next_page
        return false unless @session.has_selector?(pagination_selector)

        next_button = find_next_button
        return false if next_button[:class].include?('disabled')

        init_list(next_button[:href])
        true
      end
    end
  end
end
