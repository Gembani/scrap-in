require "salesnavot/version"


require "capybara/dsl"
require "salesnavot/search"
require "salesnavot/scrap_lead"
require "salesnavot/invite"
require "salesnavot/sent_invites"
require "salesnavot/friends"
require "salesnavot/profile_views"
require "salesnavot/session"
require "salesnavot/auth"
require "salesnavot/driver"
require "salesnavot/send_message"
require "salesnavot/threads"
require "salesnavot/messages"

module Salesnavot
  def self.setup
    Capybara.run_server = false

  end
end
