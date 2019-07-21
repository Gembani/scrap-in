Capybara.register_driver :salesnavot_driver do |app|
  driver = Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: ENV.fetch('hud_url'),
    desired_capabilities: {
      "browser": 'chrome',
      "browserName": "chrome",
      "build": "salesnavot",
      "zal:name": "linkedin",
      "zal:build": "linkedin",
      'chromeOptions': {
        'args': [
          'no-sandbox',
          'window-size=1180x800'
        ]
      }
    }
  )
  driver
end
