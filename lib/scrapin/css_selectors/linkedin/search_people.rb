module CssSelectors
  module LinkedIn
    # Selectors of ScrapIn::LinkedIn::SearchPeople.
    # Not yet checked against live LinkedIn: results are found through their profile links,
    # and a result is the list item holding the link.
    module SearchPeople
      def search_url(keywords, page)
        "https://www.linkedin.com/search/results/people/?keywords=#{URI.encode_www_form_component(keywords)}&page=#{page}"
      end

      def results_container_css
        'main'
      end

      def profile_link_css
        'a[href*="/in/"]'
      end

      def result_card_selector
        'li'
      end
    end
  end
end
