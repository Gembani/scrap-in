module CssSelectors
  module SalesNavigator
    # All css selectors used in ScrapIn::Invite Class
    module Invite
      def action_button_css
        'div.profile-topcard-actions > .artdeco-dropdown'
      end

      def connect_button_css
        '.artdeco-dropdown__item[data-control-name="connect"]'
      end

      def send_button_css
        '.button-primary-medium'
      end

      def profile_css
        '.profile-topcard'
      end

      def degree_css
        '.profile-topcard-person-entity__content > dl > dt >ul > li > span:first-child'
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
        'Pending'
      end
    end
  end
end
