require 'colorize'
require "byebug"
require "bundler/setup"
require "salesnavot"
require "dotenv/load"
require 'faker'
require 'unit/helpers/send_inmail_helpers'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include SendInmailHelpers::Success
  config.include SendInmailHelpers::Fail
end
