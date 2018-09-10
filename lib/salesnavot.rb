require 'salesnavot/version'

require 'salesnavot/helpers/tools'
require 'salesnavot/helpers/css_selectors/friends'
require 'salesnavot/helpers/css_selectors/invite'
require 'salesnavot/helpers/css_selectors/profile_views'
require 'salesnavot/helpers/css_selectors/scrap_lead'
require 'salesnavot/helpers/css_selectors/search'
require 'salesnavot/helpers/css_selectors/sent_invites'

require 'capybara/dsl'
require 'salesnavot/search'
require 'salesnavot/scrap_lead'
require 'salesnavot/invite'
require 'salesnavot/sent_invites'
require 'salesnavot/friends'
require 'salesnavot/profile_views'
require 'salesnavot/session'
require 'salesnavot/auth'
require 'salesnavot/driver'
require 'salesnavot/send_message'
require 'salesnavot/threads'
require 'salesnavot/messages'

# Our gem which will pull informations from Linkedin
module Salesnavot
  def self.setup
    Capybara.run_server = false
  end
end
