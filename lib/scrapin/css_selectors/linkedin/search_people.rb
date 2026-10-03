module CssSelectors
  module LinkedIn
    # Selectors of ScrapIn::LinkedIn::SearchPeople and SearchCompanies (checked on live LinkedIn, October 2026).
    # Each result's main link wraps its whole card (name, degree, headline, location), so results are read from
    # their links rather than from the hashed card classes.
    module SearchPeople
      def search_url(keywords, page, current_company: nil)
        params = { keywords: keywords, page: page }
        params[:currentCompany] = "[\"#{current_company}\"]" if current_company
        "https://www.linkedin.com/search/results/people/?#{URI.encode_www_form(params.compact)}"
      end

      def results_container_css
        'main'
      end

      def profile_link_css
        'a[href*="/in/"]'
      end

      # Words of the card that are buttons, not information
      def card_noise
        %w[Follow Message Connect Following Pending]
      end
    end
  end
end
