module ScrapIn
  # Goes to lead profile and scrap his phones, emails and websites
  class ScrapLead
    include Tools
    include CssSelectors::ScrapLead

    attr_reader :name, :emails, :url, :linkedin_url,
                :sales_nav_url, :links, :phones, :error, :location

    def initialize(config, session)
      @popup_open = false
      @sales_nav_url = config[:sales_nav_url] || ''
      unless @sales_nav_url.include?("linkedin.com/sales/people/")
        raise 'Lead\'s salesnav url is not valid'
      end
      @session = session  
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

    def to_json
      to_hash.to_json
    end

    def scrap_phones
      open_popup
      css = phones_block_css
      unless @session.has_selector?(css, wait: 1)
        return []
      end
      phones = @session.all(css)
      phones.collect do |phone|
        phone.find(phone_css).text
      end
    end

    def scrap_emails
      open_popup
      css = emails_block_css
      unless @session.has_selector?(css, wait: 1)
        return []
      end
      emails = @session.all(emails_block_css)
      emails.collect do |email|
        email.find(email_css).text
      end
    end

    def scrap_links
      open_popup
      css = links_block_css
      unless @session.has_selector?(css, wait: 1)
        return []
      end
      links = @session.all(links_block_css)
      links.collect do |link|
        link.find(link_css).text
      end
    end

    def name
      close_popup
      unless @session.has_selector?(name_css)
        raise CssNotFound.new(name_css)
      end
      current_name = @session.find(name_css).text
      if out_of_network?(current_name)
        raise OutOfNetworkError.new(@sales_nav_url)
      end
      current_name
    end

    def location
      close_popup
      unless @session.has_selector?(location_css)
        raise CssNotFound.new(location_css)
      end
      @session.find(location_css).text
    end

    def first_degree?
      close_popup
      unless @session.has_selector?(degree_css, wait: 1)
        raise CssNotFound.new(degree_css)
      end
      (@session.find(degree_css).text == '1st')
    end

    private
    def go_to_url 
      if @session.current_url != @sales_nav_url
        @session.visit @sales_nav_url
        return true
      end
      return false
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
      return true
    end
  end
end