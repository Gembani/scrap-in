module CssSelectors
  module SalesNavigator
    # All css selectors used in ScrapIn::ScrapLead Class
    module ScrapLead
      def phones_block_css
        '.contact-info-form__phone div.contact-info-form__phone-readonly-group'
      end

      def location_css
        '.profile-topcard__location-data'
      end

      def emails_block_css
        '.contact-info-form__email div.contact-info-form__email-readonly-group'
      end

      def links_block_css
        '.contact-info-form__website-readonly-group'
      end

      def infos_css
        'button.profile-topcard__contact-info-show-all'
      end

      def close_popup_css
        "//*[@role='dialog']/button[@aria-label='Dismiss']"
      end

      def phone_css
        '.contact-info-form__phone-readonly-text a'
      end

      def email_css
        '.contact-info-form__email-readonly-text a'
      end

      def link_css
        '.contact-info-form__website-readonly-text a'
      end

      def name_css
        '.profile-topcard-person-entity__name'
      end

      def degree_css
        '.label-16dp'
      end

      def profile_actions_css
        'div.profile-topcard-actions > .artdeco-dropdown'
      end

      def linkedin_link_css
        ".artdeco-dropdown__item[data-control-name='view_linkedin']"
      end

      def body
        'body'
      end
    end
  end
end
