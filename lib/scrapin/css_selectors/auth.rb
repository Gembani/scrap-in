module CssSelectors
  # All css selectors used in ScrapIn::LinkedIn::Auth Class
  module Auth
    def username_input_css
      '#username'
    end

    def password_input_css
      '#password'
    end

    def alert_header_css
      '.alert-center__list-header'
    end

    def password_error_css
      '#error-for-password'
    end

    def linkedin_placeholder
      'Search'
    end

    def sales_navigator_placeholder
      'Search by keywords or boolean'
    end
    
    def new_sales_navigator_placeholder
      'Search'
    end

    def security_check_css
      'main h1'
    end
  end
end
