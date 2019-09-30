require 'scrapin/version'

require 'scrapin/helpers/tools'
require 'scrapin/helpers/css_selectors/invite'
require 'scrapin/helpers/css_selectors/scrap_lead'
require 'scrapin/helpers/css_selectors/search'
require 'scrapin/helpers/css_selectors/send_inmail.rb'
require 'scrapin/helpers/css_selectors/sent_invites'

require 'scrapin/helpers/css_selectors/linkedin/friends'
require 'scrapin/helpers/css_selectors/linkedin/invite.rb'
require 'scrapin/helpers/css_selectors/linkedin/profile_views.rb'
require 'scrapin/helpers/css_selectors/linkedin/scrap_lead.rb'
require 'scrapin/helpers/css_selectors/linkedin/send_message.rb'
require 'scrapin/helpers/css_selectors/linkedin/threads.rb'


require 'scrapin/helpers/css_selectors/sales_navigator/messages.rb'
require 'scrapin/helpers/css_selectors/sales_navigator/threads.rb'


require 'scrapin/errors/captcha_error'
require 'scrapin/errors/css_not_found'
require 'scrapin/errors/lead_is_friend'
require 'scrapin/errors/out_of_network_error'

require 'scrapin/sales_navigator/css_selectors/auth'

require 'scrapin/linkedin/friends'
require 'scrapin/linkedin/scrap_lead'
require 'scrapin/linkedin/send_message'
require 'scrapin/linkedin/threads'
require 'scrapin/linkedin/profile_views'


require 'scrapin/sales_navigator/auth'
require 'scrapin/sales_navigator/invite'
require 'scrapin/sales_navigator/messages'
require 'scrapin/sales_navigator/send_inmail'

require 'capybara/dsl'
require 'scrapin/driver'
require 'scrapin/linkedin/invite'
require 'scrapin/linkedin_data_from_name'
require 'scrapin/linkedin_salesnav_converter'
require 'scrapin/messages'
require 'scrapin/scrap_lead'
require 'scrapin/search'
require 'scrapin/sent_invites'
require 'scrapin/session'
require 'scrapin/sales_navigator/threads'
require 'scrapin/thread_from_name'

# Our gem which will pull informations from Linkedin
module ScrapIn
  def self.setup
    Capybara.run_server = false
  end
end
