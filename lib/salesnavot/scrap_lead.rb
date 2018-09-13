module Salesnavot
  # Goes to lead profile and scrap his phones, emails and websites
  class ScrapLead
    include Tools
    include CssSelectors::ScrapLead

    attr_reader :name, :emails, :url, :linkedin_url,
                :sales_nav_url, :links, :phones, :error

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
    end

    def execute
      @session.visit @sales_nav_url

      find_lead_name
      find_lead_degree
      scrap_datas
    end

    def to_hash
      {
        name: @name,
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
      find_and_click(infos_css)
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

    def find_lead_degree
      unless @session.has_selector?(degree_css)
        @first_degree = false
        return
      end
      @first_degree = (@session.find(degree_css).text == '1st')
    end
  end
end
