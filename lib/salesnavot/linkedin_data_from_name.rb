module Salesnavot
  class LinkedInDataFromName
    def initialize(session)
      @session = session
    end

    def target_page
      'https://www.linkedin.com/feed/'
    end

    def sales_nav_button_css
      '.pv-s-profile-actions--view-profile-in-sales-navigator'
    end

    def execute(name)
      @session.visit(target_page)
      raise "Error" unless @session.has_selector?('.core-rail')
      search_input = @session.find("input[role='combobox'][placeholder='Search']")
      search_input.set(name)
      raise "Error" unless @session.has_selector?('artdeco-typeahead-deprecated-results-container')
      search_input.send_keys(:arrow_down)
      search_input.send_keys(:enter)
      raise "Error" unless @session.has_selector?(sales_nav_button_css)
      @session.find(sales_nav_button_css).click
      linkedin_url=@session.current_url
      tabs = @session.driver.browser.window_handles
      @session.driver.browser.switch_to.window(tabs.last)
      sales_nav_url = @session.current_url
      {linkedin_url: linkedin_url.chomp("/"), salesnav_url: sales_nav_url}
    end
  end
end

#ember6440
