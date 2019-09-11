# Helpers for SalesNavMessages unit tests
module MessagesHelpers
  def message_content(count)
    "Message content #{count}"
  end

  def create_conversation(array)
    array.each_with_index do |element, count|
      has_selector(element, content_css, wait: 5)
      has_selector(element, sender_css, wait: 2, visible: false)

      content = { 'innerHTML' => message_content(count) }
      content = { 'innerHTML' => "beginnning of the conversation" } if count.zero?

      # Alternate senders to see incoming and outgoing directions
      sender = count.even? ? { 'innerHTML' => '   You   ' } : { 'innerHTML' => '   Sender   ' }
      allow(element).to receive(:find).with(content_css, wait: 5).and_return(content)
      allow(element).to receive(:first).with(sender_css, wait: 2, visible: false).and_return(sender)
    end
  end
end
