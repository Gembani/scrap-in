Capybara.register_driver :salesnavot_driver do |app|
  driver = Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: ENV.fetch('hud_url'),
    desired_capabilities: {
      "browser": 'chrome',
      'chromeOptions': {
        'args': [
          'no-sandbox',
          'headless',
          'disable-gpu',
          'window-size=1280x800'
        ]
      }
    }
  )
  driver
end
