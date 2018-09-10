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
      return false unless visit_target_page(@sales_nav_url)
      return false if friend?
      return false unless click_and_connect
      lead_invited?
    end

    def visit_target_page(link)
      @session.visit(link)
      return false unless @session.has_selector?(profile_css)
      true
    end

    def friend?
      if @session.has_selector?(degree_css, wait: 4)
        return true if @session.find(degree_css).text == '1st'
        @error = 'Already friends'
        return false
      end
      @error = 'No connections. Not a friend'
      false
    end

    def lead_email_required?
      if @session.has_selector?(form_email_css, wait: 3)
        @error = "Lead's email is required to connect"
        return false
      end
      true
    end

    def invitation_window_closed?
      !@session.has_selector?(form_css)
    end

    def click_and_connect
      return false unless find_and_click(action_button_css)
      return false unless find_and_click(connect_button_css)
      return false unless lead_email_required?

      @session.fill_in form_invitation_id, with: @content
      find_and_click(send_button_css)
    end

    def lead_invited?
      return false unless invitation_window_closed?
      return false unless find_and_click(action_button_css)
      unless @session.has_selector?(pending_connection_css)
        @error = "Can't find pending connection button"
        return false
      end
      true
    end
  end
end
