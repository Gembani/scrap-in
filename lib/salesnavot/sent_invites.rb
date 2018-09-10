module Salesnavot
  # Goes to "Sent invitations" page, and scrap all leads that were invited
  class SentInvites
    include Tools
    attr_reader :invited_leads
    def initialize(session)
      @session = session
      @invited_leads = []
    end

    def target_page
      'https://www.linkedin.com/mynetwork/invitation-manager/sent/'
    end

    def nth_invited_lead_css(count, invitation: true)
      if invitation
        ".mn-invitation-list li:nth-child(#{count + 1}) .invitation-card__name"
      else
        ".mn-invitation-list li:nth-child(#{count + 1})"
      end
    end

    def find_lead_name(count)
      if @session.has_selector?(nth_invited_lead_css(count), wait: 3)
        item = @session.find(nth_invited_lead_css(count))
        scroll_to(item)
        name = item.text
        unless name.empty?
          @invited_leads.push name
          yield name
        end
      end
    end

    def execute(num_times = 50)
      return unless init_list(target_page)

      count = 0
      num_times.times.each do
        unless @session.has_selector?(nth_invited_lead_css(count, invitation: false), wait: 10)
          count = 0
          break unless next_page
        end
        find_lead_name(count) { |name| yield name }
        count += 1
      end
    end

    def init_list(link)
      @session.visit(link)
      return false unless @session.has_selector?('.mn-invitation-list')
      true
    end

    def pagination_selector
      'a.mn-invitation-pagination__control-btn'
    end

    def find_next_button
      pagination_buttons = @session.all(pagination_selector)
      pagination_buttons.each do |button|
        next unless button.has_selector?(
          'li-icon[aria-label="Next item"]',
          wait: 1
        )
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
