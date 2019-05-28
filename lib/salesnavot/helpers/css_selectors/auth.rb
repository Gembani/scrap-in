module CssSelectors
  # All css selectors used in Salesnavot::Auth Class
  module Auth
    def email_input(type = :selector)
      type.to_sym
      return '#username' if type == :id
      '#username'
    end

    def password_input(type = :selector)
      return '#password' if type == :id
      '#password'
    end

    def login_button(type = :selector)
      return 'btn__primary--large' if type == :id
      'btn__primary--large'
    end

    def insight_list_css
      '#insights-list'
    end
  end
end
