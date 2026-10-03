module CssSelectors
  module LinkedIn
    # Selectors of ScrapIn::LinkedIn::ScrapCompany (checked on live LinkedIn, October 2026):
    # the about page lists its facts as <dt> label / <dd> value.
    module ScrapCompany
      def employees_link_css
        'a[href*="currentCompany"]'
      end

      def company_id_regex
        /currentCompany=(?:%5B|\[)(?:%22|")(\d+)/
      end

      def company_name_css
        'h1'
      end

      def about_value_xpath(label)
        ".//dt[normalize-space()='#{label}']/following-sibling::dd[1]"
      end

      def overview_xpath
        ".//h2[normalize-space()='Overview']/following::p[1]"
      end

      def about_labels
        { website: 'Website', industry: 'Industry', company_size: 'Company size', headquarters: 'Headquarters' }
      end
    end
  end
end
