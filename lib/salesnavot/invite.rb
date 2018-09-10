module Salesnavot
  class Invite
    include Tools
    attr_reader :error
    def initialize(sales_nav_url, session, content)
      @sales_nav_url = sales_nav_url
      @session = session
      @error = ''
      @content = content
    end

    def go_to(link)
      @session.visit(link)
      return false unless @session.has_selector?('.profile-topcard')
      true
    end

    def friend?
      if @session.has_selector?('.m-type--degree', wait: 4)
        if @session.find('.m-type--degree').text == '1st'
          return true
        else
          @error = 'Already friends'
          return false
        end
      end
      @error = 'No connections. Not a friend'
      false
    end

    def action_button_css
      '.profile-topcard-actions__overflow-toggle'
    end

    def connect_button_css
      '.connect'
    end

    def send_button_css
      '.button-primary-medium'
    end

    def lead_email_required?
      if @session.has_selector?('#connect-cta-form__email')
        @error = "Lead's email is required to connect"
        return false
      end
      true
    end

    def invitation_window_closed?
      !@session.has_selector?('connect-cta-form')
    end

    def click_and_connect
      return false unless find_and_click(action_button_css)
      return false unless find_and_click(connect_button_css)
      return false unless lead_email_required?
      @session.fill_in 'connect-cta-form__invitation', with: @content
      find_and_click(send_button_css)
    end

    def lead_invited?
      return false unless invitation_window_closed?
      return false unless find_and_click(action_button_css)
      unless @session.has_selector?('.pending-connection')
        @error = "Can't find .pending connection button"
        return false
      end
      true
    end

    def execute
      return false unless go_to(@sales_nav_url)
      return false if friend?
      return false unless click_and_connect
      lead_invited?
    end
  end
end
