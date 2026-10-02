require 'selenium-webdriver'
require 'capybara/dsl'

# Talks to a remote Chrome (see docker-compose.yml). CHROME_PROFILE_DIR points
# at a persistent profile so cookies survive between runs and we don't have
# to log in (and hit captchas) every time.
Capybara.register_driver :scrapin_driver do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_preference('intl.accept_languages', 'en')
  options.add_argument('--lang=en-US')
  options.add_argument('--window-size=1920,1080')
  options.add_argument('--start-maximized')
  options.add_argument('--disable-blink-features=AutomationControlled')
  options.add_argument("--user-data-dir=#{ENV['CHROME_PROFILE_DIR']}") if ENV['CHROME_PROFILE_DIR']

  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: ENV.fetch('HUB_URL', 'http://localhost:4444'),
    options: options
  )
end
