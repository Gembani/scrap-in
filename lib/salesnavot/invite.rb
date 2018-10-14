module Salesnavot
  # Goes to a lead profile page, and invite the lead
  class Invite
    include Tools
    include CssSelectors::Invite
    attr_reader :error
    def initialize(sales_nav_url, session, content)
      @sales_nav_url = sales_nav_url
      @session = session
      @error_types = [:already_pending, :out_of_network, :already_friends, :email_required, :invitattion_form_didnot_close]
      @error_messages = {
        already_pending: 'Invitation is already pending ...',
        out_of_network: 'Lead is out of network.',
        already_friends: 'Already friends',
        email_required:  "Lead's email is required to connect",
        invitattion_form_didnot_close: 'Invitation form did not close'
      }
      @error = nil
      @content = content
    end
    def error_message
      return nil if @error.nil?
      @error_messages[@error]
    end
    def execute
      if @sales_nav_url.include?('OUT_OF_NETWORK')
        @error = :out_of_network
        return false
      end
      visit_target_page(@sales_nav_url)
      if initially_pending?
        @error = :already_pending
        return false
      end
      find_and_click(action_button_css)
      if friend?
        @error = :already_friends
        return false
      end
      return false unless click_and_connect
      lead_invited?
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
      @error = :invitattion_form_didnot_close
      false
    end

    def click_and_connect
      find_and_click(action_button_css)
      find_and_click(connect_button_css)
      if lead_email_required?
        @error = :email_required
        return false
      end
      @session.fill_in form_invitation_id, with: @content
      find_and_click(send_button_css)
      true
    end

    def initially_pending?
      find_and_click(action_button_css)
      return @session.has_selector?(pending_connection_css, wait: 4)
    end

    def pending_after_invite?
      # this isn't working anymore probably a bug on their end.
      find_and_click(action_button_css)
      unless @session.has_selector?(pending_connection_css, wait: 4)
        #@error = "Can't find pending connection button"
        return false
      end
      true
    end

    def lead_invited?
      visit_target_page(@sales_nav_url)
      true
    end
  end
end
