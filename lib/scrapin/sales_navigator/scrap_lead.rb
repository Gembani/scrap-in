module ScrapIn
  module SalesNavigator
    # Goes to lead profile and scrap his phones, emails and websites
    class ScrapLead
      include Tools
      include CssSelectors::SalesNavigator::ScrapLead

      attr_reader :name, :emails, :url, :linkedin_url,
                  :sales_nav_url, :links, :phones, :error, :location

      def initialize(config, session)
        @popup_open = false
        @sales_nav_url = config[:sales_nav_url] || ''
        unless @sales_nav_url.include?('linkedin.com/sales/people/') || @sales_nav_url.include?('https://www.linkedin.com/sales/profile/')
          raise 'Lead\'s salesnav url is not valid'
        end

        @session = session
      end

      def execute
        warn '[DEPRECATION] `execute` is deprecated. This call can safely be removed'
      end

      def to_hash
        {
          name: name,
          location: location,
          sales_nav_url: sales_nav_url,
          first_degree: first_degree?,
          linkedin_url: linkedin_url
        }.merge(scrap_datas)
      end

      def scrap_datas
        data = {}
        %w[phones links emails].each do |name|
          data[name.to_sym] = method("scrap_#{name}").call
        end
        data
      end

      def to_json(*_args)
        to_hash.to_json
      end
      
      def scrap_phones
        open_popup
        css = phones_block_css
        return [] unless @session.has_selector?(css, wait: 1)

        phones = @session.all(css)
        phones.collect do |phone|
          phone.find(phone_css).text
        end
      end

      def scrap_emails
        open_popup
        css = emails_block_css
        return [] unless @session.has_selector?(css, wait: 1)

        emails = @session.all(emails_block_css)
        emails.collect do |email|
          email.find(email_css).text
        end
      end

      def scrap_links
        open_popup
        css = links_block_css
        return [] unless @session.has_selector?(css, wait: 1)

        links = @session.all(links_block_css)
        links.collect do |link|
          link.find(link_css).text
        end
      end

      def name
        close_popup
        raise CssNotFound, name_css unless @session.has_selector?(name_css)

        current_name = @session.find(name_css).text
        raise OutOfNetworkError, @sales_nav_url if out_of_network?(current_name)

        current_name
      end

      def linkedin_url
        close_popup
        find_and_click(@session, profile_actions_css)
        find_and_click(@session, linkedin_link_css)
        @session.driver.browser.switch_to.window(@session.driver.browser.window_handles.last)
        url = @session.current_url 
        @session.driver.browser.execute_script('window.close()', @session.find(body))
        @session.driver.browser.switch_to.window(@session.driver.browser.window_handles.first)
        url
      end             

      def location
        close_popup
        raise CssNotFound, location_css unless @session.has_selector?(location_css)

        @session.find(location_css).text
      end

      def sales_nav_url
        @session.current_url
      end

      def first_degree?
        close_popup
        raise CssNotFound, degree_css unless @session.has_selector?(degree_css, wait: 1)

        (@session.find(degree_css).text == '1st')
      end

      private

      def go_to_url
        if @session.current_url != @sales_nav_url
          @session.visit @sales_nav_url
          return true
        end
        false
      end

      def out_of_network?(name)
        name.include?('LinkedIn')
      end

      def open_popup
        go_to_url
        return false if @popup_open

        find_and_click(@session, infos_css)
        @popup_open = true
      end

      def close_popup
        go_to_url
        return false unless @popup_open

        find_xpath_and_click(close_popup_css)
        @popup_open = false
        true
      end
    end
  end
end
