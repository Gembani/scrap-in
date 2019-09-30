require 'scrapin/version'


require 'capybara/dsl'

Dir[File.expand_path('./lib/scrapin/helpers/**/*.rb')].sort.each { |f| require f }

non_helpers = Dir[File.expand_path('./lib/scrapin/**/*.rb')].filter {|value| !value.include?("/lib/scrapin/helpers/")}

non_helpers.sort.each { |f| require f }

# Our gem which will pull informations from Linkedin
module ScrapIn
  def self.setup
    Capybara.run_server = false
  end
end
