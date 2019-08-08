module CssSelectors
  # All css selectors used in Salesnavot::Search Class
  module Search
    def results_loaded_css
      'ol.search-results__result-list '\
        'li.search-results__result-item div.search-results__result-container'
    end

    def page_css(page)
      "[data-page-number='#{page}']"
    end

    def no_results_css
      '.search-results__no-results'
    end

    def name_css
      'dt.result-lockup__name a'
    end

    def searches_hover_css
      '.nav-saved-searches'
    end

    def searches_container_css
      '.global-nav-saved-searches-flyout'
    end

    def searches_list_css
      'ul.saved-searches-list'
    end

    def pagination_list_css
      '.search-results__pagination-list'
    end
  end
end