require 'salesnavot/version'

require 'salesnavot/helpers/tools'
require 'salesnavot/helpers/css_selectors/friends'
require 'salesnavot/helpers/css_selectors/invite'
require 'salesnavot/helpers/css_selectors/profile_views'
require 'salesnavot/helpers/css_selectors/scrap_lead'
require 'salesnavot/helpers/css_selectors/search'
require 'salesnavot/helpers/css_selectors/sent_invites'
require 'salesnavot/helpers/css_selectors/auth'
require 'salesnavot/helpers/css_selectors/send_message.rb'
require 'salesnavot/helpers/css_selectors/send_inmail.rb'
require 'salesnavot/errors/css_not_found'
require 'salesnavot/errors/lead_is_friend'
require 'salesnavot/helpers/css_selectors/sales_nav_threads.rb'

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
require 'salesnavot/send_inmail'
require 'salesnavot/threads'
require 'salesnavot/sales_nav_threads'
require 'salesnavot/messages'
require 'salesnavot/linkedin_salesnav_converter'
require 'salesnavot/linkedin_data_from_name'
require 'salesnavot/thread_from_name'

# Our gem which will pull informations from Linkedin
module Salesnavot
  def self.setup
    Capybara.run_server = false
  end
end
