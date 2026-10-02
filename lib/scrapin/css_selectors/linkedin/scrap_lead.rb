module CssSelectors
  module LinkedIn
    # All css used in ScrapIn::ScrapLead class.
    # Profile classes are hashed (b4lmff...) and change per deploy, so we anchor on
    # componentkey/id suffixes, tags and visible labels instead.
    module ScrapLead
      def top_card_css
        '[componentkey$="Topcard"]'
      end

      def name_css
        'h2'
      end

      def degree_regex
        /\A·\s*(1st|2nd|3rd)/
      end

      def contact_info_text
        'Contact info'
      end

      def contact_info_css
        '[id$="ContactInfoDetailSection"]'
      end

      # The value paragraphs following a label ("Email", "Phone", "Website") in the contact info dialog
      def contact_values_xpath(label)
        ".//p[normalize-space()='#{label}']/following-sibling::p"
      end
    end
  end
end
