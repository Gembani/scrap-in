module SendInmailHelpers
  def lead_is_not_friended
    has_selector(degree_css, wait: 5)
    has_not_selector(degree_css, text: degree_text, wait: 5)
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
end
