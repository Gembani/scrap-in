
module CssSelectors
  # All css selectors used in ScrapIn::Auth Class
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

    def alert_header_xpath
      '//*/section/header/h2[contains(.,"Alerts")]'
    end

    def captcha_xpath
      '//*[@id="app__container"]/main/h1[contains(.,"Let\'s do a quick security check")]'
    end
  end
end
