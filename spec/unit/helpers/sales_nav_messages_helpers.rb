# Helpers for SalesNavMessages unit tests
module SalesNavMessagesHelpers
  def create_conversation(array)
    array.each_with_index do |element, count|
      has_selector(element, content_css, wait: 5)
      has_selector(element, sender_css, wait: 2, visible: false)
      content = { 'innerHTML' => "Message content #{count}" }
      sender = count.even? ? { 'innerHTML' => '   You   ' } : { 'innerHTML' => '   Sender   ' } # Alternate senders to see incoming and outgoing directions
      allow(element).to receive(:find).with(content_css, wait: 5).and_return(content)
      allow(element).to receive(:first).with(sender_css, wait: 2, visible: false).and_return(sender)
    end
  end
end
