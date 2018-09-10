module CssSelectors
  module ProfileViews
    def profile_view_css(count)
      'section.me-wvmp-viewers-list '\
      "article[data-control-name=\"profileview_single\"]:nth-child(#{count})"
    end

    def last_element_css(count)
      'section.me-wvmp-viewers-list '\
       "article[data-control-name=\"profileview_private\"]:nth-child(#{count})"
    end

    def viewers_list_css(*args)
      'section.me-wvmp-viewers-list' 
    end

    def name_css
      '.me-wvmp-viewer-card__name-text'
    end

    def time_ago_css
      '.me-wvmp-viewer-card__time-ago'
    end
  end
end
