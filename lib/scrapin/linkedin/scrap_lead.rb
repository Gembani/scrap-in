module ScrapIn
  module LinkedIn
    
    class ScrapLead
      include Tools
      include CssSelectors::LinkedIn::ScrapLead

      attr_reader :name, :emails, :url, :linkedin_url,
                  :sales_nav_url, :links, :phones, :error, :location

      def initialize(config, session)
        @popup_open = false
        @linkedin_url = config[:linkedin_url] || ''
        unless @linkedin_url.include?("linkedin.com/in/")
          raise 'Lead\'s linkedin url is not valid'
        end
        @session = session
        @info_popup = @linkedin_url + 'detail/contact-info/'
      end
      
      def execute 
        warn "[DEPRECATION] `execute` is deprecated. This call can safely be removed"
      end
      
      def to_hash
        byebug
        {
          name: name,
          location: location,
          linkedin_url: @linkedin_url,
          first_degree: first_degree?
        }.merge(scrap_datas)
      end

      def scrap_datas
        data = {}
        %w[phone links emails].each do |name|
          data[name.to_sym] = method("scrap_#{name}").call
        end
        data
      end

      def name
        close_popup
        check_and_find(@session, name_css, wait: 5).text
      end

      def location
        close_popup
        check_and_find(@session, location_css, wait: 5).text
      end

      def first_degree?
        close_popup
        check_and_find(@session, degree_css, wait: 5).text
      end
      
      def scrap_emails
        open_popup
        email_list = []
        email = check_and_find(@session, emails_css, wait: 5).text
        email_list << email
        email_list
      end

      def scrap_links
        open_popup
        links_list = []
        websites = check_and_find_all(@session, websites_css, wait: 5)
        websites.each_with_index do |link, index|
          links_list << websites[index].text.split[0]
        end
        links_list
      end

      def scrap_phone
        open_popup
        phone = []
        phone << check_and_find_first(@session, phone_css, wait: 5).text
      end

      private
      def go_to_url(url)
        if @session.current_url != url
          @session.visit(url)
          return true
        end
        return false
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