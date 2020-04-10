module ScrapIn
  module LinkedIn
    # Goes to lead profile and scrap his phones, emails and websites on LinkedIn
    class ScrapLead
      include Tools
      include CssSelectors::LinkedIn::ScrapLead

      attr_reader :name, :emails, :url, :linkedin_url,
                  :sales_nav_url, :links, :phones, :error, :location

      def initialize(config, session)
        @popup_open = false
        @linkedin_url = config[:linkedin_url] || ''
        @get_sales_nav_url = config[:get_sales_nav_url] || false
        raise 'Lead\'s linkedin url is not valid' unless @linkedin_url.include?('linkedin.com/in/')
        
        @session = session
        @info_popup = @linkedin_url + 'detail/contact-info/'
      end

      def execute
        warn '[DEPRECATION] `execute` is deprecated. This call can safely be removed'
      end

      def to_hash
        data = {
          name: name,
          location: location,
          linkedin_url: @linkedin_url,
          first_degree: first_degree?
        }.merge(scrap_datas)
        data[:sales_nav_url] = sales_nav_url if @get_sales_nav_url
        data
      end

      def scrap_datas
        data = {}
        %w[phones links emails].each do |name|
          data[name.to_sym] = method("scrap_#{name}").call
        end
        data
      end

      def sales_nav_url
        close_popup
        find_and_click(@session, sales_nav_button_css)
        @session.driver.browser.switch_to.window(@session.driver.browser.window_handles.last)
        url = @session.current_url 
        @session.driver.browser.execute_script('window.close()', @session.find('body'))
        @session.driver.browser.switch_to.window(@session.driver.browser.window_handles.first)
        url
      end

      def name
        close_popup
        check_and_find(@session, name_css, wait: 5).text
      end

      def location
        close_popup
        check_and_find(@session, location_css, wait: 5).text
      end

      # We expect the user to only scrap 1st degree leads
      def first_degree?
        close_popup
        'li.pv-top-card-v3__distance-badge.inline-block.v-align-text-bottom.t-16.t-black--light.t-normal span.dist-value'
        check_and_find(@session, degree_css, wait: 5).text == '1st'
      end

      def scrap_emails
        open_popup
        email_list = []
        return email_list unless @session.has_selector?(emails_css, wait: 5)

        email = @session.find(emails_css, wait: 5).text
        email_list << email
        email_list
      end

      def scrap_links
        open_popup
        links_list = []
        return links_list unless @session.has_selector?(websites_css, wait: 5)

        websites = @session.all(websites_css, wait: 5)
        websites.each_with_index do |_link, index|
          links_list << websites[index].text.split[0]
        end
        links_list
      end

      def scrap_phones
        open_popup
        phones = []
        return phones unless @session.has_selector?(phone_css, wait: 5)

        phones << @session.first(phone_css, wait: 5).text
        phones
      end

      private

      def go_to_url(url)
        @session.visit(url) if @session.current_url != url
      end

      def open_popup
        go_to_url(@info_popup)
        return false if @popup_open

        @popup_open = false
      end

      def close_popup
        go_to_url(@linkedin_url)
        return false unless @popup_open

        @popup_open = false
      end
    end
  end
end
