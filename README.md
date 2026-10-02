# Scrapin

ScrapIn is a Ruby tool for LinkedIn and SalesNavigator. Feel free to include it in a project as a Gem.
We use it alsmost entirley SalesNavigator, we encourage you to do the same

> CAUTION: USE AT YOUR OWN RISK 
You could be banned from Linkedin if you abuse.

#### This readme is very much a WIP
We just decided to release this as open source it's what powers https://www.getzendin.com/


### We are a nice team!
If you want to use this, please feel free to contact us if you get stuck - we'll help you out.


### Prerequisites

Everything runs in Docker, so Chrome never takes over your screen:

- `browser`: Selenium Chrome. Watch it (and solve captchas / 2FA) at http://localhost:7900,
  or with a VNC client at `vnc://localhost:5900`. Its Chrome profile lives in the `chrome-profile`
  volume, so you stay logged in between runs and LinkedIn sees the same "device" every time.
- `scrapin`: Ruby 3.4 with the gem mounted at `/app`, so edits on your machine are picked up immediately.

On macOS with Colima: `colima start && brew install docker-compose`.

### Installing

    cp .env.example .env   # test urls; username / password are optional
    docker compose build
    docker compose up -d browser

Without a username / password, `ScrapIn::Session.new(nil, nil, true)` opens the login page and waits for
you to log in at http://localhost:7900. The Chrome profile keeps you logged in after that.

### Playing with a live session

    docker compose run --rm scrapin bin/console
    >> session                                  # logs in, open http://localhost:7900 to watch
    >> session.linkedin_scrap_threads.execute(5) { |name, link| puts name, link }
    >> session.capybara.all('.msg-conversation-listitem').count   # try selectors

If LinkedIn shows a captcha or a verification code, login waits (`CAPTCHA_TIMEOUT`, default 300s)
for you to solve it over VNC instead of failing.

To start from a clean browser (logged out): `docker compose down -v`.

## Running the tests

### Integration tests

The integrations tests are divided in two files:

- Linkedin: `spec/linkedin_spec.rb`
- SalesNavigator: `spec/sales_navigator_spec.rb`

#### .env

The `.env` file should contain the following (see `.env.example`), in order to run every test:

    username=
    password=
    
    l_scrap_lead_url=
    l_send_message_url=
    l_invite_url=
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

`username`: LinkedIn and SalesNavigator username
`password`: LinkedIn and SalesNavigator password

`l_scrap_lead_url`: a Linkedin 1st degree contact url
`l_send_message_url`: a Linkedin 1st degree contact thread url. Caution: the test actually sends a message!
`l_invite_url`: a Linkedin 2nd or 3rd degree profile url. The spec prepares an invitation and dismisses it, nothing is sent
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

    docker compose run --rm scrapin bundle exec rspec spec/linkedin_spec.rb

    docker compose run --rm scrapin bundle exec rspec spec/sales_navigator_spec.rb

### Unit tests

    docker compose run --rm scrapin bundle exec rspec spec/unit

Unit tests don't need a browser; `bundle exec rspec spec/unit` works on the host too.

## Usage

For example, if you want to use `linkedin_scrap_friends`:
```ruby
SeleniumSessionManager.instance.user_session(user.email, user.linkedin_password) do |session|
	session.linkedin_scrap_friends.execute(count) do |name, _time_str, url|
		# Code
	end
end
```

### Sharing sessions
Linkedin will ban you if you log in too often. Instead of re-logging in on every run, the browser keeps a
persistent Chrome profile (`CHROME_PROFILE_DIR`), so cookies survive between runs.

## Authors
- Nick Stock
- Sebastien Cebula
- Eugenie Ordonneau
- Sebastien Quemere
- Valentin Piatko