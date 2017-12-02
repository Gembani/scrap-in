require "capybara/dsl"
require "salesnavot/version"
require "salesnavot/search"
require "salesnavot/lead"
require "salesnavot/invite"
require "salesnavot/sent_invites"
require "salesnavot/friends"
require "salesnavot/profile_views"
require "salesnavot/session"
require "salesnavot/auth"

module Salesnavot
  def self.setup
    Capybara.run_server = false


  end
end
