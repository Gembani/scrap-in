# frozen_string_literal: true

module Salesnavot
  class SendInmail
    include Tools
    include CssSelectors::SendInmail

    def initialize(session, profile_url, subject, message)
      @session = session
      @profile_url = profile_url
      @message = message
      @subject = subject
      @error = 'An error occured when sending the inmail.'
    end

    def execute
      visit_profile
      return false if friend?

      click_message_link
      write_subject
      write_message
      send_message
      raise @error unless message_sent?

      true
    end

    def visit_profile
      puts 'Visiting profile...'

      @session.visit(@profile_url)

      button_found = check_until(500) do
        @session.has_selector?('button', text: 'Message', wait: 0)
      end
      raise 'Error: Button not found' unless button_found

      puts 'Profile has been visited.'
    end

    def friend?
      raise css_error(degree_css) unless @session.has_selector?(degree_css, wait: 5)

      @session.has_selector?(degree_css, text: degree_text, wait: 5)
    end

    def click_message_link
      puts 'Opening message window...'
      @session.click_button 'Message'
      puts 'Message window has been opened.'
    end

    def write_subject
      puts 'Writting subject...'
      subject_field = @session.find_field(placeholder: subject_placeholder)
      subject_field.send_keys(@subject)
      puts 'Subject has been written.'
    end

    def write_message
      puts 'Writing message...'
      message_field = @session.find_field(placeholder: message_placeholder)
      message_field.send_keys(@message)
      puts 'Message has been written.'
    end

    def send_message
      puts 'Sending message...'
      @session.click_button 'Send'
      puts 'Message has been sent.'
      true
    end

    def message_sent?
      puts 'Checking the message has been sent...'
      puts 'Visiting again the profile'
      visit_profile
      puts 'Clicking on Message button'
      click_message_link
      check = check_until(500) do
        @session.has_selector?(message_container, text: @message, wait: 5)
      end
      return false unless check

      puts 'Confirmed'
      true
    end
  end
end
