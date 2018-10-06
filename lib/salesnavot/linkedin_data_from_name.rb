module Salesnavot
  # Goes to "Sent invitations" page, and scrap all leads that were invited
  class LinkedInDataFromName
    def initialize(session)
      @session = session
    end

    def target_page
      'https://www.linkedin.com/feed/'
    end

    def sales_nav_button_css
      '[data-control-name="view_profile_in_sales_navigator"]'
    end

    def execute(name)
      @session.visit(target_page)
      raise "Error" unless @session.has_selector?('.core-rail')
      seach_input = @session.find("input[role='combobox'][placeholder='Search']")
      seach_input.set(name)
      raise "Error" unless @session.has_selector?('artdeco-typeahead-deprecated-results-container')
      seach_input.send_keys(:arrow_down)
      seach_input.send_keys(:enter)
      raise "Error" unless @session.has_selector?(sales_nav_button_css)
      {linkedin_url: @session.current_url.chomp("/"), salesnav_url: @session.find(sales_nav_button_css)[:href]}
    end
  end
end

#ember6440
