module ScrapIn
  module LinkedIn
    # Goes to lead profile and scrap his phones, emails and websites on LinkedIn
    class ScrapLead
      include Tools
      include CssSelectors::LinkedIn::ScrapLead

      attr_reader :linkedin_url

      def initialize(config, session)
        @popup_open = false
        @linkedin_url = config[:linkedin_url] || ''
        raise 'Lead\'s linkedin url is not valid' unless @linkedin_url.include?('linkedin.com/in/')

        @session = session
      end

      def execute
        warn '[DEPRECATION] `execute` is deprecated. This call can safely be removed'
      end

      def to_hash
        {
          name: name,
          location: location,
          linkedin_url: @linkedin_url,
          first_degree: first_degree?
        }.merge(scrap_datas)
      end

      def scrap_datas
        data = {}
        %w[phones links emails].each do |name|
          data[name.to_sym] = method("scrap_#{name}").call
        end
        data
      end

      def name
        check_and_find(top_card, name_css, wait: 5).text
      end

      # The location is the last line before "· Contact info", it may not exist
      def location
        lines = top_card_lines
        index = lines.index(contact_info_text)
        return nil unless index

        candidates = lines[0...index].reject { |line| line == '·' || line.match?(degree_regex) }
        candidates.size > 1 ? candidates.last : nil
      end

      # We expect the user to only scrap 1st degree leads
      def first_degree?
        degree = top_card_lines.find { |line| line.match?(degree_regex) }
        degree&.match(degree_regex)&.captures&.first == '1st'
      end

      def scrap_emails
        contact_values('Email')
      end

      def scrap_links
        contact_values('Website').map { |text| text.split.first }
      end

      def scrap_phones
        contact_values('Phone')
      end

      private

      def top_card
        close_popup
        check_and_find(@session, top_card_css, wait: 10)
      end

      def top_card_lines
        top_card.all('p').map { |paragraph| paragraph.text.strip }
      end

      def contact_values(label)
        open_popup
        dialog = check_and_find(@session, contact_info_css, wait: 5)
        dialog.all(:xpath, contact_values_xpath(label), wait: 1).map { |value| value.text.strip }
      end

      # The contact info overlay only opens from the profile, visiting its url redirects to the profile
      def open_popup
        return if @popup_open

        top_card.click_link(contact_info_text)
        @popup_open = true
      end

      def close_popup
        on_profile = @session.current_url.start_with?(@linkedin_url.chomp('/'))
        @session.visit(@linkedin_url) if @popup_open || !on_profile
        @popup_open = false
      end
    end
  end
end
