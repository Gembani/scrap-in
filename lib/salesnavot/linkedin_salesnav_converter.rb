module Salesnavot
  # Goes to 'profile' page and get the url of it in Sales Navigator mode
  class LinkedinSalesnavConverter
    include Tools
    attr_reader :sales_nav_url

    def initialize(linkedin_url, session)
      @session = session
      @sales_nav_url = nil
      @linked_url = linkedin_url
    end
    def sales_nav_button_css
      '.pv-s-profile-actions--view-profile-in-sales-navigator'
    end
    def execute
      puts "Going to the profile page"
      visit_target_page
      puts "Clicking on the button 'View in Sales Navigator'"
      @session.find(sales_nav_button_css).click
      tabs = @session.driver.browser.window_handles
      puts "Saving the url of the Sales navigator tab"
      @session.driver.browser.switch_to.window(tabs.last)
      @sales_nav_url = @session.current_url
    end



    def visit_target_page
      @session.visit(@linked_url)
      raise css_error(sales_nav_button_css) unless @session.has_selector?(sales_nav_button_css)
    end

  end
end
