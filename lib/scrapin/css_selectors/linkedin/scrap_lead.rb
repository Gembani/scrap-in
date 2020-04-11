module CssSelectors
  module LinkedIn
    # All css used in ScrapIn::ScrapLead class
    module ScrapLead
      def name_css
        'li.inline.t-24.t-black.t-normal.break-words' # find
      end
      
      def sales_nav_button_css
        '.pv-s-profile-actions--view-profile-in-sales-navigator'
      end

      def phone_css
        'span.t-14.t-black.t-normal' # first
      end

      def emails_css
        'section.pv-contact-info__contact-type.ci-email div a' # find
      end

      def location_css
        'li.t-16.t-black.t-normal.inline-block' # find
      end

      def degree_css
        '.pv-top-card--list .distance-badge .dist-value' # find
      end

      def websites_css
        'section.pv-contact-info__contact-type.ci-websites ul li' # find each + .text.split
      end
    end
  end
end
