module Salesnavot
  # Goes to a lead profile page, and invite the lead
  class Invite
    include Tools
    include CssSelectors::Invite
    attr_reader :error
    def initialize(sales_nav_url, session, content)
      @sales_nav_url = sales_nav_url
      @session = session
      @error = ''
      @content = content
    end

    def execute
      visit_target_page(@sales_nav_url)
      # return false if friend?
      if friend?
        @error = 'Already friends'
        return false
      end
      return false unless click_and_connect
      return lead_invited?
    end

    private

    def visit_target_page(link)
      @session.visit(link)
      raise css_error(profile_css) unless @session.has_selector?(profile_css)
    end

    def friend?
      if @session.has_selector?(degree_css, wait: 4)
        return true if @session.find(degree_css).text == '1st'
      end
      false
    end

    def lead_email_required?
      return true if @session.has_selector?(form_email_css, wait: 3)
      false
    end

    def invitation_window_closed?
      return true unless @session.has_selector?(form_css)
      @error = 'Invitation form did not close'
      false
    end

    def click_and_connect
      find_and_click(action_button_css)
      find_and_click(connect_button_css)
      if lead_email_required?
        @error = "Lead's email is required to connect"
        return false
      end

      @session.fill_in form_invitation_id, with: @content
      find_and_click(send_button_css)
      true
    end

    def lead_invited?
      return false unless invitation_window_closed?
      find_and_click(action_button_css)
      unless @session.has_selector?(pending_connection_css)
        @error = "Can't find pending connection button"
        return false
      end
      true
    end
  end
end
