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
require 'salesnavot/messages'
require 'salesnavot/linkedin_salesnav_converter'
require 'salesnavot/linkedin_data_from_name'
require 'salesnavot/thread_from_name'

# Our gem which will pull informations from Linkedin
module Salesnavot
  class CssNotFound < StandardError
    attr_reader :selector

    def initialize(selector = '', text = '')
      @selector = selector
      @message = "Css selector not found -> #{selector}"
      @message = "#{@message} with text: #{text}" unless text.empty?
      super(@message)
    end
  end

  class LeadIsFriend < StandardError
    attr_reader :selector

    def initialize(profile_url: '')
      message = "The current lead is friended. Profile url: #{profile_url}"
      @message = message
      @profile_url = profile_url
      super(@message)
    end
  end

  class ClickButtonFailed < StandardError
    attr_reader :selector

    def initialize(button_text: '')
      message = "Unable to click on button with text: #{button_text}"
      @message = message
      @button_text = button_text
      super(@message)
    end
  end

  def self.setup
    Capybara.run_server = false
  end
end
