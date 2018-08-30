module Salesnavot
  # Goes to lead profile and scrap his phones, emails and websites
  class ScrapLead
    attr_reader :name, :emails,
                :phone_number, :url, :linkedin_url,
                :sales_nav_url, :links, :phones
    def initialize(config, session)
      @sales_nav_url = config[:sales_nav_url] || ''
      @emails = config[:emails] || []
      @phones = config[:phones] || []
      @first_degree = config[:first_degree] || false
      @links = config[:links] || []
      @session = session
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

    def scrap_linkedin_url
      @session.find('button.profile-topcard-actions__overflow-toggle').click
      @session.find('.copy-linkedin').click
      @linkedin_url = IO.popen('pbpaste', 'r+').read
    end

    def scrap_datas
      @session.find('button.profile-topcard__contact-info-show-all').click
      %w[phones emails links].each do |name|
        method("scrap_#{name}").call
      end
    end

    def execute
      @session.visit @sales_nav_url
      @name = @session.find('.profile-topcard-person-entity__name').text
      @first_degree = (@session.find('.m-type--degree').text == '1st')
      return unless @session.has_selector?(infos_selector)

      scrap_linkedin_url
      scrap_datas
    end
  end
end
