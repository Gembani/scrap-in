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


require 'selenium/webdriver'
module Selenium
  module WebDriver
    module Remote
      class Bridge
        alias_method :original_execute, :execute
        def execute(*args)
          if args.first == :new_session && File.exist?('mock_response_selenium.json')
            return JSON.parse(File.read('mock_response_selenium.json'))
          else
            data = original_execute(*args)
          end
          if args.first == :new_session
            File.write('mock_response_selenium.json', {value: data['value']}.to_json)
          end
          data
        end
      end
    end
  end
end

Capybara::Selenium::Driver.class_eval do
  def cleanup_browser
    begin
      @browser.quit if @browser
    rescue StandardError
      # Browser must have already gone
    end
  end


  def quit

    puts "not quiting selenium session"
  rescue Errno::ECONNREFUSED
    # Browser must have already gone
  end
end

