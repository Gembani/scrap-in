module CssSelectors
  # All css selectors used in ScrapIn::ProfileViews Class
  module ProfileViews
    def public_profile_css(count)
      'section.me-wvmp-viewers-list '\
      "div[data-control-name=\"profileview_single\"]:nth-child(#{count})"
    end

    def semi_private_css(count)
      'section.me-wvmp-viewers-list '\
       "div[data-control-name=\"profileview_single_semi\"]:nth-child(#{count})"
    end

    def last_element_css(count)
      'section.me-wvmp-viewers-list '\
       "div[data-control-name=\"profileview_private\"]:nth-child(#{count})"
    end

    def viewers_list_css
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
