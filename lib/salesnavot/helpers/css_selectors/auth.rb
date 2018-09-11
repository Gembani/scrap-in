module CssSelectors
  # All css selectors used in Salesnavot::Auth Class
  module Auth
    def email_input(type = :selector)
      type.to_sym
      return 'session_key-login' if type == :id
      '#session_key-login'
    end

    def password_input(type = :selector)
      return 'session_password-login' if type == :id
      '#session_password-login'
    end

    def login_button(type = :selector)
      return 'btn-primary' if type == :id
      '#btn-primary'
    end

    def insight_list_css
      '#insights-list'
    end
  end
end
