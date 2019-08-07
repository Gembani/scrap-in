Capybara.register_driver :scrapin_driver do |app|
  driver = Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: ENV.fetch('hud_url'),
    desired_capabilities: {
      "browser": 'chrome',
      "browserName": "chrome",
      "build": "scrapin",
      "zal:name": "linkedin",
      "zal:build": "linkedin",
      "idleTimeout": "3600",
      'chromeOptions': {
        'args': [
          'no-sandbox',
          'window-size=1920x1080'
        ]
      }
    }
  )
  driver
end
