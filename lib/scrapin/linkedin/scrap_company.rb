module ScrapIn
  module LinkedIn
    # Reads a company page's about tab: name, website, industry, size, headquarters, overview
    class ScrapCompany
      include Tools
      include CssSelectors::LinkedIn::ScrapCompany

      attr_reader :company_url

      def initialize(session, company_url)
        match = company_url.to_s.match(%r{(https?://(?:www\.)?linkedin\.com/(?:company|school)/[^/?#]+)})
        raise ArgumentError, "Not a LinkedIn company url: #{company_url}" unless match

        @session = session
        @company_url = "#{match[1]}/"
      end

      def to_hash
        visit_about
        data = { name: check_and_find(@session, company_name_css, wait: 10).text.strip, linkedin_company_url: @company_url }
        about_labels.each { |key, label| data[key] = about_value(label) }
        data.merge(overview: text_at(overview_xpath), company_id: company_id, employees: employees_text)
      end

      # LinkedIn's numeric id, from the page's "N employees" link: it filters people searches by company
      def company_id
        visit_about
        employees_link&.[](:href).to_s[company_id_regex, 1]
      end

      def employees_text
        employees_link&.text&.strip
      end

      private

      def visit_about
        url = "#{@company_url}about/"
        @session.visit(url) unless @session.current_url.to_s.start_with?(url)
      end

      def employees_link
        @session.first(employees_link_css, minimum: 0, wait: 2)
      end

      def about_value(label)
        text_at(about_value_xpath(label))
      end

      def text_at(xpath)
        node = @session.first(:xpath, xpath, minimum: 0, wait: 1)
        node&.text&.strip
      end
    end
  end
end
