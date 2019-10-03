require 'scrapin/version'


require 'capybara/dsl'
Dir[File.expand_path('../scrapin/helpers/**/*.rb', __FILE__)].sort.each { |f| require f }

non_helpers = Dir[File.expand_path('../scrapin/**/*.rb', __FILE__)].filter {|value| !value.include?("/lib/scrapin/helpers/")}

non_helpers.sort.each { |f| require f }

# Our gem which will pull informations from Linkedin
module ScrapIn
  def self.setup
    Capybara.run_server = false
  end
end
