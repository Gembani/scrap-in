require 'scrapin/version'

require 'scrapin/helpers/tools'
require 'scrapin/helpers/css_selectors/friends'
require 'scrapin/helpers/css_selectors/invite'
require 'scrapin/helpers/css_selectors/profile_views'
require 'scrapin/helpers/css_selectors/scrap_lead'
require 'scrapin/helpers/css_selectors/search'
require 'scrapin/helpers/css_selectors/sent_invites'
require 'scrapin/sales_navigator/css_selectors/auth'
require 'scrapin/helpers/css_selectors/send_message.rb'
require 'scrapin/helpers/css_selectors/send_inmail.rb'
require 'scrapin/errors/css_not_found'
require 'scrapin/errors/lead_is_friend'
require 'scrapin/errors/out_of_network_error'
require 'scrapin/errors/captcha_error'

require 'scrapin/helpers/css_selectors/sales_nav_threads.rb'
require 'scrapin/helpers/css_selectors/sales_nav_messages.rb'

require 'capybara/dsl'
require 'scrapin/search'
require 'scrapin/scrap_lead'
require 'scrapin/invite'
require 'scrapin/sent_invites'
require 'scrapin/friends'
require 'scrapin/profile_views'
require 'scrapin/session'
require 'scrapin/sales_navigator/auth'
require 'scrapin/driver'
require 'scrapin/send_message'
require 'scrapin/send_inmail'
require 'scrapin/threads'
require 'scrapin/sales_nav_threads'
require 'scrapin/sales_nav_messages'
require 'scrapin/messages'
require 'scrapin/linkedin_salesnav_converter'
require 'scrapin/linkedin_data_from_name'
require 'scrapin/thread_from_name'

# Our gem which will pull informations from Linkedin
module ScrapIn
  def self.setup
    Capybara.run_server = false
  end
end
