module Salesnavot
  # Goes to lead profile and scrap his phones, emails and websites
  class ScrapLead
    include Tools
    include CssSelectors::ScrapLead

    attr_reader :name, :emails, :url, :linkedin_url,
                :sales_nav_url, :links, :phones, :error, :location

    def initialize(config, session)
      @name = ''
      @linkedin_url = ''
      @url = ''
      @sales_nav_url = config[:sales_nav_url] || ''
      @emails = config[:emails] || []
      @phones = config[:phones] || []
      @first_degree = config[:first_degree] || false
      @links = config[:links] || []
      @session = session
      @error = ''
      @location = config[:location] || ''
    end

    def execute
      unless @sales_nav_url.include?("linkedin.com/sales/people/")
        @error = 'Lead\'s salesnav url is not valid'
      end
      @session.visit @sales_nav_url
      lead_name = @session.find(name_css).text
      if out_of_network?(@sales_nav_url, name = lead_name)
        @error = 'Lead is out of network.'
        return
      end

      find_lead_name
      find_lead_degree
      find_location
      scrap_datas
    end

    def to_hash
      {
        name: @name,
        location: @location,
        sales_nav_url: @sales_nav_url,
        emails: @emails,
        phones: @phones,
        first_degree: @first_degree,
        links: @links
      }
    end

    def to_json
      to_hash.to_json
    end

    private

    def scrap_datas
      begin
        find_and_click(infos_css)
      rescue
        @error = 'No infos at all, or button has been changed'
        raise css_error(infos_css)
      end
      %w[phones links emails].each do |name|
        method("scrap_#{name}").call
      end
    end

    def scrap_phones
      css = phones_block_css
      unless @session.has_selector?(css, wait: 1)
        @error << 'No phones found.'
        return
      end
      phones = @session.all(css)
      phones.each do |phone|
        value = phone.find(phone_css).text
        @phones << value
      end
    end

    def scrap_emails
      css = emails_block_css
      unless @session.has_selector?(css, wait: 1)
        @error << 'No emails found.'
        return
      end
      emails = @session.all(emails_block_css)
      emails.each do |email|
        value = email.find(email_css).text
        @emails << value
      end
    end

    def scrap_links
      css = links_block_css
      unless @session.has_selector?(css, wait: 1)
        @error << 'No links found.'
        return
      end
      links = @session.all(links_block_css)
      links.each do |link|
        value = link.find(link_css).text
        @links << value
      end
    end

    def find_lead_name
      unless @session.has_selector?(name_css)
        @error = 'No name found'
        raise css_error(name_css)
      end
      @name = @session.find(name_css).text
    end

    def find_location
      unless @session.has_selector?(location_css)
        @error = 'No location found'
        raise css_error(location_css)
      end
      @location = @session.find(location_css).text
      location_css
    end

    def find_lead_degree
      unless @session.has_selector?(degree_css)
        @first_degree = false
        return
      end
      @first_degree = (@session.find(degree_css).text == '1st')
    end
  end
end
