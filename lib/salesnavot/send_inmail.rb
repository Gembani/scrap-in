module Salesnavot
  class SendInmail
    include Tools
    include CssSelectors::SendInmail

    def initialize(session, profile_url, subject, inmail_message)
      @session = session
      @profile_url = profile_url
      @inmail_message = inmail_message
      @subject = subject
      @error = 'An error occured when sending the inmail.'
    end

    def execute
      visit_profile
      search_for_message_button
      friend?
      click_message_link
      write_subject
      write_message
      send_message
      message_sent?
      true
    end

    private

    def visit_profile
      puts 'Visiting profile...'
      @session.visit(@profile_url)
      puts 'Profile has been visited.'
    end

    def search_for_message_button
      puts 'Checking if message button has appeared on profile page'
      button_found = check_until(500) do
        @session.has_selector?(message_button_css, text: message_button_text, wait: 0)
      end
      raise CssNotFound.new(message_button_css, text = message_button_text) unless button_found

      puts 'Message button has been found.'
      true
    end

    def friend?
      raise CssNotFound, degree_css unless @session.has_selector?(degree_css, wait: 5)

      is_friend = @session.has_selector?(degree_css, text: degree_text, wait: 5)
      # it checks if the lead is friended (degree == '1st')
      raise LeadIsFriend.new(profile_url: @profile_url) if is_friend
    end

    def click_message_link
      puts 'Opening message window...'
      @session.click_button(message_button_text)
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
      message_field.send_keys(@inmail_message)
      puts 'Message has been written.'
    end

    def send_message
      puts 'Sending message...'
      @session.click_button send_button_text
      puts 'Message has been sent.'
    end

    def message_sent?
      puts 'Checking the message has been sent...'
      puts 'Visiting again the profile'
      visit_profile
      puts 'Clicking on Message button'
      click_message_link
      message_exists = check_until(500) do
        @session.has_selector?(message_container, text: @inmail_message, wait: 5)
      end
      raise CssNotFound.new(message_container, text: @inmail_message) unless message_exists

      puts 'Confirmed'
    end
  end
end
