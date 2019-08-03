# frozen_string_literal: true

module SendInmailHelpers
  module Success
    def visit_succeed
      allow(session).to receive(:visit).with(profile_url)
    end

    def searching_for_message_button_succeed
      allow(session).to receive(:has_selector?)
        .with(message_button_css, text: message_button_text, wait: 0).and_return(true)
    end

    def lead_is_not_friended
      allow(session).to receive(:has_selector?).with(degree_css, wait: 5).and_return(true)
      allow(session).to receive(:has_selector?).with(degree_css, text: degree_text, wait: 5).and_return(false)
    end

    def click_message_link_succeed
      allow(session).to receive(:click_button).with(message_button_text).and_return(true)
    end

    def write_subject_succeed
      subject_field = instance_double('Capybara::Node::Element')
      allow(subject_field).to receive(:send_keys).with(subject_text)
      allow(session).to receive(:find_field).with(placeholder: subject_placeholder).and_return(subject_field)
    end

    def write_message_succeed
      message_field = instance_double('Capybara::Node::Element')
      allow(message_field).to receive(:send_keys).with(inmail_message)
      allow(session).to receive(:find_field).with(placeholder: message_placeholder).and_return(message_field)
    end

    def send_message_succeed
      allow(session).to receive(:click_button).with(send_button_text)
    end

    def message_has_been_sent_successfully
      allow(session).to receive(:has_selector?).with(message_container, text: inmail_message, wait: 5).and_return(true)
    end
  end

  module Fail
    def message_button_not_found
      allow(session).to receive(:has_selector?)
        .with(message_button_css, text: message_button_text, wait: 0).and_return(false)
    end

    def friend_degree_selector_not_found
      allow(session).to receive(:has_selector?).with(degree_css, wait: 5).and_return(false)
    end

    def lead_is_friended
      allow(session).to receive(:has_selector?).with(degree_css, text: degree_text, wait: 5).and_return(true)
    end

    def click_on_message_button_fails
      allow(session).to receive(:click_button).with(message_button_text)
                                              .and_raise(Capybara::ElementNotFound, "Unable to find button '#{message_button_text}' that is not disabled")
    end

    def subject_field_not_found
      exception = "Unable to find field that is not disabled with placeholder #{subject_placeholder}"
      allow(session).to receive(:find_field).with(placeholder: subject_placeholder)
                                            .and_raise(Capybara::ElementNotFound, exception)
    end

    def message_field_not_found
      exception = "Unable to find field that is not disabled with placeholder #{message_placeholder}"
      allow(session).to receive(:find_field).with(placeholder: message_placeholder)
                                            .and_raise(Capybara::ElementNotFound, exception)
    end

    def send_button_not_found
      allow(session).to receive(:click_button).with(send_button_text)
                                              .and_raise(Capybara::ElementNotFound, "Unable to find button '#{send_button_text}' that is not disabled")
    end

    def sent_message_not_found
      allow(session).to receive(:has_selector?).with(message_container, text: inmail_message, wait: 5).and_return(false)
    end
  end
end
