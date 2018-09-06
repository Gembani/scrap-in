module Salesnavot
  # Goes to lead profile and scrap his phones, emails and websites
  class ScrapLead
    attr_reader :name, :emails, :url, :linkedin_url,
                :sales_nav_url, :links, :phones, :error
    def initialize(config, session)
      @sales_nav_url = config[:sales_nav_url] || ''
      @emails = config[:emails] || []
      @phones = config[:phones] || []
      @first_degree = config[:first_degree] || false
      @links = config[:links] || []
      @session = session
      @error = ''
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

    def phone_selector
      '.contact-info-form__phone div.contact-info-form__phone-readonly-group'
    end

    def email_selector
      '.contact-info-form__email div.contact-info-form__email-readonly-group'
    end

    def link_selector
      '.contact-info-form__link div.contact-info-form__website-readonly-group'
    end

    def infos_selector
      'button.profile-topcard__contact-info-show-all'
    end

    def scrap_phones
      return unless @session.has_selector?(phone_selector, wait: 1)
      phones = @session.all(phone_selector)
      phones.each do |phone|
        value = phone.find('.contact-info-form__phone-readonly-text a').text
        @phones << value
      end
    end

    def scrap_emails
      return unless @session.has_selector?(email_selector, wait: 1)
      emails = @session.all(email_selector)
      emails.each do |email|
        value = email.find('.contact-info-form__email-readonly-text a').text
        @emails << value
      end
    end

    def scrap_links
      return unless @session.has_selector?(link_selector, wait: 1)
      links = @session.all(link_selector)
      links.each do |link|
        value = link.find('.contact-info-form__website-readonly-text a').text
        @links << value
      end
    end

    def find_lead_name
      unless @session.has_selector?('.profile-topcard-person-entity__name')
        @error = 'No name found'
        return false
      end
      @name = @session.find('.profile-topcard-person-entity__name').text
      true
    end

    def find_lead_degree
      unless @session.has_selector?('.m-type--degree')
        @first_degree = false
        return
      end
      @first_degree = (@session.find('.m-type--degree').text == '1st')
    end

    def scrap_datas
      return false unless find_and_click(infos_selector)
      %w[phones emails links].each do |name|
        method("scrap_#{name}").call
      end
    end

    def find_and_click(css)
      unless @session.has_selector?(css)
        @error = "Cannot find action button for css = #{css}"
        return false
      end
      @session.find(css).click
      true
    end

    def execute
      @session.visit @sales_nav_url

      return false unless find_lead_name
      find_lead_degree
      return false unless scrap_datas
    end
  end
end
