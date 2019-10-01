
module CssSelectors
  module LinkedIn
    # All css selectors used in ScrapIn::LinkedIn::Auth Class
    module Auth
      def email_input
        '#username'
      end

      def password_input
        '#password'
      end

      def login_button
        'btn__primary--large'
      end

      def alert_header_xpath
        '//*/section/header/h2[contains(.,"Alerts")]'
      end
    end
  end
end
