module Scrapin
  include Tools
  module LinkedIn
    
    class ScrapLead
      include CssSelectors::LinkedIn::ScrapLead

      attr_reader :name, :emails, :url, :linkedin_url,
                  :sales_nav_url, :links, :phones, :error, :location

      def initialize(config, session)
        byebug
        @popup_open = false
        @linkedin_url = config[:linkedin_url] || ''
        unless @linkedin_url.include?("linkedin.com/in/")
          raise 'Lead\'s linkedin url is not valid'
        end
        @session = session
        @info_popup = @linkedin_url + '/detail/contact-info/'
      end

      def execute 
        warn "[DEPRECATION] `execute` is deprecated. This call can safely be removed"
      end

      def to_hash
        {
          name: name,
          location: location,
          sales_nav_url: @sales_nav_url,
          first_degree: first_degree?
        }.merge(scrap_datas)
      end

      def scrap_datas
        data = {}
        %w[phones links emails].each do |name|
          data[name.to_sym] = method("scrap_#{name}").call
        end
        data
      end

      def name
        close_popup
      end

      def location
        close_popup
      end

      def first_degree?
        close_popup
      end
      
      def scrap_emails
        open_popup
      end

      def scrap_links
        open_popup
      end

      def scrap_phones
        open_popup
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
      end

      def close_popup
        go_to_url(@linkedin_url)
      end
    end
  end
end