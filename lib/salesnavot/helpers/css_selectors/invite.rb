module CssSelectors
  # All css selectors used in Salesnavot::Invite Class
  module Invite
    def action_button_xpath
      "/HTML/BODY[1]/DIV[4]/MAIN[1]/DIV[1]/DIV[1]/DIV[1]/DIV[2]/DIV[1]/ARTDECO-DROPDOWN[1]/ARTDECO-DROPDOWN-TRIGGER[1]"
    end

    def connect_button_css
      '.connect'
    end

    def send_button_css
      '.button-primary-medium'
    end

    def profile_css
      '.profile-topcard'
    end

    def degree_css
      '.m-type--degree'
    end

    def form_email_css
      '#connect-cta-form__email'
    end

    def form_invitation_id
      'connect-cta-form__invitation'
    end

    def form_css
      '.connect-cta-form'
    end

    def pending_connection_css
      '.pending-connection'
    end
  end
end
