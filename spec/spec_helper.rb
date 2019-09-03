require 'deep-cover'
require 'simplecov'
if ENV["COVERAGE"]
  DeepCover.start
  DeepCover::AutoRun.run!('.').report!(**DeepCover.config)
  # SimpleCov.start do 
  #   add_filter '/spec/'
  # end
end
require 'bundler/setup'
require 'byebug'
require 'colorize'
require 'dotenv/load'
require 'faker'
require 'helpers/mock_capybara'
require 'helpers/tools_helpers'
require 'scrapin'
require 'unit/helpers/send_inmail_helpers'
require 'unit/helpers/messages_helpers'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include ToolsHelpers
  config.include MockCapybara
  config.include SendInmailHelpers
  config.include MessagesHelpers
  
  config.before(:each) do
    disable_method(:sleep)
  end
end
