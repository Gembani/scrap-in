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
      '[data-control-name="view_profile_in_sales_navigator"]'
    end
    def execute
      visit_target_page
      @sales_nav_url = @session.find(sales_nav_button_css)[:href]
      @sales_nav_url
    end



    def visit_target_page
      @session.visit(@linked_url)
      raise css_error(sales_nav_button_css) unless @session.has_selector?(sales_nav_button_css)
    end

  end
end
