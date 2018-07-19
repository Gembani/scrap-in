# Salesnavot

@session.driver.browser.save_screenshot("testingsssss.png")
@session.fill_in('verification-code',with: "002358")
@session.click_on("Submit")



## Important thing to know about Capybara and find / fill_in methods


The visit behavior is driver dependent and there is no guarantee a page has fully loaded (however you define fully) when it returns. The waiting methods in Capybara are those that wait for specific elements. So

find(:css, '#blah')

will wait (up to Capybara.default_max_wait_time seconds) for an element with id of 'blah' to appear on the page. If you don't know anything about the structure of the page you are visiting and what elements you expect to be on it then the only way would be via a timeout.

Source: https://stackoverflow.com/questions/45858810/capybara-wait-for-page-to-load-all-elements-completely-with-ruby
