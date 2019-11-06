# ScrapIn

ScrapIn is a Ruby tool for LinkedIn and SalesNavigator.

> CAUTION: USE AT YOUR OWN RISK
You could be banned from Linkedin if you abuse.

## Getting Started

### Prerequisites

- Download Selenium Standalone server [here](https://www.seleniumhq.org/download/).
- Run the server in a different terminal with:
```
        java -jar selenium-server-standalone-3.141.59.jar
```
- Add these to your `.env` file:
```
        driver=scrapin_driver
        hud_url=http://localhost:4444/wd/hub
```
- Make sure you have the latest version of Chrome, or download it [here](https://www.google.fr/chrome/?brand=CHBD&gclid=Cj0KCQiA-4nuBRCnARIsAHwyuPo3JnlrBmylDUYKOdDcS4i4HVePmuRXgZxm4EBqirGgGV3JQ8mVP6MaAjLQEALw_wcB&gclsrc=aw.ds).

> Selenium Standalone server allows you to run multiple tests in the same session, mainly to avoid a Captcha.
It creates a file named `mock_response_selenium.json`. If you close the Chrome page, you have to delete this file before re-running the tests.

### Installing

- Clone the project
- Install the gems:
```
        bundle install
```
- Fill the `.env` properly and run the tests

## Running the tests

### Integration tests

The integrations tests are divided in two files:

- Linkedin: `spec/linkedin_spec.rb`
- SalesNavigator: `spec/salesnavot_spec.rb`

#### .env

The .env file should contain *ce qui suit*, in order to run every test:
```
    driver=scrapin_driver
    hud_url=http://localhost:4444/wd/hub
    
    username=
    password=
    
    l_scrap_lead_url=
    l_send_message_url=
    l_invite_url_connect_button_visible=
    l_invite_url_must_click_on_more=
    l_scrap_messages_url=
    
    s_scrap_search_list=
    s_scrap_lead_url=
    s_invite_url=
    s_invite_message=
    s_invite_url_2=
    s_invite_message_2=
    s_send_message_url=
    s_send_message_url_2=
    s_send_inmail_url=
```
`username`: LinkedIn and SalesNavigator username
`password`: LinkedIn and SalesNavigator password

`l_scrap_lead_url`: a Linkedin 1st degree contact url
`l_send_message_url`: a Linkedin 1st degree contact thread url. Caution: the test actually sends a message!
`l_invite_url_connect_button`: a Linkedin 2nd or 3rd degree profile url where the connect button is visible
`l_invite_url_must_click_on_more`: a Linkedin 2nd or 3rd degree profile url where the connect button is in the 'More...' menu
`l_scrap_messages_url`: a Linkedin 1st degree contact thread url

`s_scrap_search_list`: a SalesNavigator saved search url
`s_scrap_lead_url`: a SalesNavigator 1st degree contact url
`s_invite_url`: a SalesNavigator 2nd or 3rd degree profile url
`s_invite_url_2`: a SalesNavigator 1st degree profile url
`s_send_message_url`: a SalesNavigator 1st degree contact thread url. Caution: the test actually sends a message!
`s_send_message_url_2`: a SalesNavigator 1st degree contact thread url. Caution: the test actually sends a message!
`s_send_inmail_url`: a SalesNavigator 3rd degree contact thread url. Caution: the test actually sends an inmail!
`s_scrap_messages_url`: a SalesNavigator 1st degree contact thread url
`s_scrap_messages_url_2`: a SalesNavigator 1st degree contact thread url
`s_send_inmail_url`: a SalesNavigator 3rd degree contact profile url

#### Running Commands
```
bundle exec rspec spec/linkedin_spec.rb
```
```
bundle exec rspec spec/salesnav_spec.rb
```

### Unit tests
```
bundle exec rspec spec/unit
```
> It is recommended to keep the Chrome page in the foreground to make sure the tests are working properly.

## Usage

For example, if you want to use `linkedin_scrap_friends`:
```ruby
SeleniumSessionManager.instance.user_session(user.email, user.linkedin_password) do |session|
  session.linkedin_scrap_friends.execute(count) do |name, _time_str, url|
    # Code
  end
end
```
## Authors

- Nick Stock
- Sebastien Cebula
- Eugenie Ordonneau
- Sebastien Quemere
- Valentin Piatko