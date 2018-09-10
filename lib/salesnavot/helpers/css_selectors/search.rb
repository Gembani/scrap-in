module CssSelectors
  module Search
    def results_loaded_css
      'ol.search-results__result-list li.search-results__result-item div.search-results__result-container'
    end

    def page_css(page)
      ".cursor-pointer [data-page-number='#{page}']"
    end

    def no_results_css
      '.search-results__no-results'
    end
  end
end
