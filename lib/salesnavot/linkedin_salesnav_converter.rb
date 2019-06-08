module Salesnavot
  # Goes to 'profile views' page and get all persons who viewed our profile
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
      visit_target_page
      @session.find(sales_nav_button_css).click
      tabs = @session.driver.browser.window_handles
      @session.driver.browser.switch_to.window(tabs.last)
      @sales_nav_url = @session.current_url
    end



    def visit_target_page
      @session.visit(@linked_url)
      raise css_error(sales_nav_button_css) unless @session.has_selector?(sales_nav_button_css)
    end

  end
end
