require 'spec_helper'
require 'tempfile'

RSpec.describe ScrapIn::LinkedIn::SendMessage do
  include CssSelectors::LinkedIn::SendMessage

  let(:session) { instance_double(Capybara::Session) }
  let(:field) { instance_double(Capybara::Node::Element, text: '') }
  let(:composer) { instance_double(Capybara::Node::Element) }
  let(:conversation) { instance_double(Capybara::Node::Element) }
  let(:button) { instance_double(Capybara::Node::Element, disabled?: false) }
  let(:input) { instance_double(Capybara::Node::Element) }
  let(:url) { 'https://www.linkedin.com/messaging/thread/test/' }
  let(:message) { 'A reviewed message' }
  let(:video) { nil }
  let(:filename) { video ? File.basename(video) : 'sample.mp4' }
  let(:sender) { described_class.new(session, url, message, video: video, upload_timeout: 3, confirmation_timeout: 3) }
  let(:history) { [event('old', message)] }
  let(:new_event) { event('new', message, video: !!video) }
  let(:preview) do
    Capybara.string(%(<div class="msg-form__attachment-preview"><h3 data-test-msg-cross-pillar-uploaded-attachments-list-presenter__attachment-name>#{filename}</h3><p data-test-msg-cross-pillar-uploaded-attachments-list__attached>Attached</p></div>)).find(attachment_preview_css)
  end

  def event(id, text, video: false, outgoing: true, native_video: false, acknowledged: true)
    sent = acknowledged ? '<svg data-test-msg-cross-pillar-message-sending-indicator-presenter__sending-indicator--sent></svg>' : ''
    attachment = if native_video
      %(<div class="msg-s-event-listitem__message-bubble"><div class="msg-s-event-with-indicator"><video src="blob:https://example.test/synthetic-video"></video>#{sent}</div></div>)
    elsif video
      %(<div class="msg-s-event-with-indicator"><a class="msg-s-event-listitem__attachment" href="https://example.test/video">#{filename}</a>#{sent}</div>)
    else
      ''
    end
    Capybara.string(%(<li class="msg-s-message-list__event"><div data-event-urn="#{id}" class="msg-s-event-listitem #{outgoing ? '' : 'msg-s-event-listitem--other'}"><div class="msg-s-event-with-indicator"><p class="msg-s-event-listitem__body">#{text}</p>#{sent}</div>#{attachment}</div></li>)).find(message_events_css)
  end

  before do
    allow(session).to receive(:current_url).and_return(url)
    allow(session).to receive(:visit)
    allow(session).to receive(:has_selector?).with(message_field_css, wait: 0).and_return(true)
    allow(session).to receive(:has_selector?).with(messaging_shadow_host_css, wait: 0).and_return(false)
    allow(session).to receive(:find).with(message_field_css).and_return(field)
    allow(field).to receive(:find).with(:xpath, 'ancestor::form[1]').and_return(composer)
    allow(composer).to receive(:find).with(:xpath, conversation_xpath).and_return(conversation)
    allow(composer).to receive(:find).with(message_field_css).and_return(field)
    allow(composer).to receive(:find).with(send_button_css).and_return(button)
    allow(composer).to receive(:first).with(send_button_css, minimum: 0, wait: 0).and_return(button)
    allow(composer).to receive(:has_selector?).with(attachment_preview_css, wait: 0).and_return(false)
    allow(composer).to receive(:has_selector?).with(attachment_error_css, wait: 0).and_return(false)
    allow(composer).to receive(:has_selector?).with(attachment_busy_css, wait: 0).and_return(false)
    allow(composer).to receive(:all).with(attachment_preview_css, wait: 0).and_return([preview])
    allow(field).to receive(:send_keys)
    allow(button).to receive(:native).and_return(button)
    allow(button).to receive(:[]).with('aria-disabled').and_return(nil)
    allow(conversation).to receive(:all).with(message_events_css, wait: 0) { history.dup }
    allow(button).to receive(:click) { history << new_event }
    allow(composer).to receive(:find).with(video_input_css, visible: :all).and_return(input)
    allow(input).to receive(:set)
  end

  it 'preserves the three positional argument text-only API' do
    expect(sender.execute).to be true
    expect(sender.status).to eq(:sent)
    expect(sender.thread_url).to eq(url)
    expect(field).to have_received(:send_keys).with(message)
    expect(input).not_to have_received(:set)
  end

  it 'never executes the same action twice' do
    expect(sender.execute).to be true
    expect(sender.execute).to be false
    expect(button).to have_received(:click).once
  end

  it 'does not confirm an old identical message' do
    allow(button).to receive(:click)
    expect(sender.execute).to be false
    expect(sender.status).to eq(:ambiguous)
    expect(sender.execute).to be false
    expect(button).to have_received(:click).once
  end

  it 'does not confirm an optimistic outgoing event without server acknowledgement' do
    allow(button).to receive(:click) { history << event('new', message, acknowledged: false) }
    expect(sender.execute).to be false
    expect(sender.status).to eq(:ambiguous)
  end

  it 'does not confirm a newly arrived incoming identical message' do
    allow(button).to receive(:click) { history << event('incoming', message, outgoing: false) }
    expect(sender.execute).to be false
    expect(sender.status).to eq(:ambiguous)
  end

  it 'does not confuse a rerender of an old event with a new message' do
    allow(button).to receive(:click) { history.replace([event('old', message)]) }
    expect(sender.execute).to be false
  end

  it 'refuses Send when existing event identities are missing' do
    history.replace([event('', message)])
    expect(sender.execute).to be false
    expect(sender.status).to eq(:confirmation_unavailable)
    expect(button).not_to have_received(:click)
  end

  it 'treats a click transport failure as ambiguous without retry' do
    allow(button).to receive(:click).and_raise(Selenium::WebDriver::Error::WebDriverError, 'connection lost')
    expect(sender.execute).to be false
    expect(sender.status).to eq(:ambiguous)
    sender.execute
    expect(button).to have_received(:click).once
  end

  it 'reports unavailable messaging without writing or sending' do
    allow(session).to receive(:has_selector?).with(message_field_css, wait: 0).and_return(false)
    expect(sender.execute).to be false
    expect(sender.status).to eq(:unavailable)
    expect(field).not_to have_received(:send_keys)
    expect(button).not_to have_received(:click)
  end

  it 'reports missing UI clearly' do
    allow(composer).to receive(:first).and_return(nil)
    expect(sender.execute).to be false
    expect(sender.status).to eq(:not_ready)
    expect(button).not_to have_received(:click)
  end

  it 'does not send with a disabled button' do
    allow(button).to receive(:disabled?).and_return(true)
    expect(sender.execute).to be false
    expect(button).not_to have_received(:click)
  end

  it 'preserves an existing text draft for human review' do
    allow(field).to receive(:text).and_return('other draft')
    expect(sender.execute).to be false
    expect(sender.status).to eq(:draft_not_empty)
    expect(field).not_to have_received(:send_keys)
  end

  it 'preserves an existing attachment draft' do
    allow(composer).to receive(:has_selector?).with(attachment_preview_css, wait: 0).and_return(true)
    expect(sender.execute).to be false
    expect(input).not_to have_received(:set)
  end

  %w[login checkpoint authwall].each do |path|
    it "stops at #{path} without browser mutation" do
      allow(session).to receive(:current_url).and_return("https://www.linkedin.com/#{path}/")
      expect(sender.execute).to be false
      expect(sender.status).to eq(:authentication_required)
      expect(session).not_to have_received(:visit)
    end
  end

  it 'reports a login redirect after navigation without writing' do
    allow(session).to receive(:visit) do
      allow(session).to receive(:current_url).and_return('https://www.linkedin.com/checkpoint/challenge/')
    end
    expect(sender.execute).to be false
    expect(sender.status).to eq(:authentication_required)
    expect(field).not_to have_received(:send_keys)
    expect(button).not_to have_received(:click)
  end

  it 'holds a challenge after the Send click as ambiguous' do
    allow(button).to receive(:click) do
      allow(session).to receive(:current_url).and_return('https://www.linkedin.com/checkpoint/challenge/')
    end
    expect(sender.execute).to be false
    expect(sender.status).to eq(:ambiguous)
    expect(button).to have_received(:click).once
  end

  it 'supports supervised preparation without Send' do
    expect(sender.execute(send: false)).to be true
    expect(sender.status).to eq(:prepared)
    expect(button).not_to have_received(:click)
  end

  it 'finds a profile composer in the interop shadow root' do
    host = instance_double(Capybara::Node::Element)
    root = instance_double(Capybara::Node::Element)
    allow(session).to receive(:has_selector?).with(message_field_css, wait: 0).and_return(false)
    allow(session).to receive(:has_selector?).with(messaging_shadow_host_css, wait: 0).and_return(true)
    allow(session).to receive(:find).with(messaging_shadow_host_css).and_return(host)
    allow(host).to receive(:shadow_root).and_return(root)
    allow(root).to receive(:has_selector?).with(message_field_css, wait: 0).and_return(true)
    allow(root).to receive(:find).with(message_field_css).and_return(field)
    expect(sender.execute(send: false)).to be true
    expect(sender.status).to eq(:prepared)
    expect(button).not_to have_received(:click)
  end

  it 'opens a message overlay for a supplied profile URL' do
    profile_sender = described_class.new(session, 'https://www.linkedin.com/in/confirmed-id/', message)
    card = double('card')
    opener = double('opener', click: true)
    allow(opener).to receive(:[]).with('href').and_return(nil)
    has_selector(session, profile_top_card_css, wait: 10)
    find(session, card, profile_top_card_css, wait: 10)
    has_selector(card, profile_message_button_css, wait: 5)
    allow(card).to receive(:first).with(profile_message_button_css, wait: 5).and_return(opener)
    expect(profile_sender.execute).to be true
    expect(opener).to have_received(:click)
  end

  it 'follows the profile Message destination without relying on overlay startup' do
    profile_url = 'https://www.linkedin.com/in/confirmed-id/'
    profile_sender = described_class.new(session, profile_url, message)
    card = double('card')
    opener = double('opener', click: true)
    allow(opener).to receive(:[]).with('href').and_return('/messaging/compose/?recipient=confirmed-id')
    allow(session).to receive(:current_url).and_return(profile_url)
    has_selector(session, profile_top_card_css, wait: 10)
    find(session, card, profile_top_card_css, wait: 10)
    has_selector(card, profile_message_button_css, wait: 5)
    allow(card).to receive(:first).with(profile_message_button_css, wait: 5).and_return(opener)
    expect(profile_sender.execute(send: false)).to be true
    expect(session).to have_received(:visit).with('https://www.linkedin.com/messaging/compose/?recipient=confirmed-id')
    expect(opener).not_to have_received(:click)
  end

  context 'with a synthetic video' do
    let(:video) { @file.path }
    around do |example|
      Tempfile.create(['sample', '.mp4']) do |file|
        @file = file
        file.write('synthetic video bytes')
        file.flush
        example.run
      end
    end

    it 'transfers the local path using Selenium detection and waits before writing/clicking' do
      allow(composer).to receive(:all).with(attachment_preview_css, wait: 0).and_return([], [preview])
      expect(input).to receive(:set).with(video).ordered
      expect(field).to receive(:send_keys).with(message).ordered
      expect(button).to receive(:click).ordered { history << new_event }
      expect(sender.execute).to be true
    end

    it 'confirms an acknowledged native player when LinkedIn omits the filename' do
      allow(button).to receive(:click) { history << event('new', message, native_video: true) }
      expect(sender.execute).to be true
      expect(sender.status).to eq(:sent)
    end

    it 'does not confirm a native player still awaiting acknowledgement' do
      allow(button).to receive(:click) { history << event('new', message, native_video: true, acknowledged: false) }
      expect(sender.execute).to be false
      expect(sender.status).to eq(:ambiguous)
    end

    it 'does not send text alone if the new event has no video' do
      allow(button).to receive(:click) { history << event('new', message) }
      expect(sender.execute).to be false
      expect(sender.status).to eq(:ambiguous)
    end

    it 'fails closed when completion evidence is absent' do
      allow(composer).to receive(:all).with(attachment_preview_css, wait: 0).and_return([])
      expect(sender.execute).to be false
      expect(sender.status).to eq(:upload_timeout)
      expect(field).not_to have_received(:send_keys)
      expect(button).not_to have_received(:click)
    end

    it 'requires explicit completion evidence, not just a named preview' do
      incomplete = Capybara.string(%(<div class="msg-form__attachment-preview">#{filename}</div>)).find(attachment_preview_css)
      allow(composer).to receive(:all).with(attachment_preview_css, wait: 0).and_return([incomplete])
      expect(sender.execute).to be false
      expect(sender.status).to eq(:upload_timeout)
      expect(button).not_to have_received(:click)
    end

    it 'rechecks readiness after text is written' do
      allow(field).to receive(:send_keys) do
        allow(composer).to receive(:all).with(attachment_preview_css, wait: 0).and_return([])
      end
      expect(sender.execute).to be false
      expect(sender.status).to eq(:not_ready)
      expect(button).not_to have_received(:click)
    end

    it 'stops when a challenge interrupts uploading' do
      allow(input).to receive(:set) do
        allow(session).to receive(:current_url).and_return('https://www.linkedin.com/checkpoint/challenge/')
      end
      expect(sender.execute).to be false
      expect(sender.status).to eq(:authentication_required)
      expect(field).not_to have_received(:send_keys)
      expect(button).not_to have_received(:click)
    end

    it 'does not treat 100 percent upload progress as completed processing' do
      processing = Capybara.string(%(<figure class="msg-form__attachment-preview msg-attachment-preview--uploading"><h3 data-test-msg-cross-pillar-uploaded-attachments-list-presenter__attachment-name>#{filename}</h3><progress max="100" value="100"></progress></figure>)).find(attachment_preview_css)
      allow(composer).to receive(:all).with(attachment_preview_css, wait: 0).and_return([processing])
      expect(sender.execute).to be false
      expect(sender.status).to eq(:upload_timeout)
      expect(button).not_to have_received(:click)
    end

    it 'does not treat a processing preview as ready' do
      allow(composer).to receive(:has_selector?).with(attachment_busy_css, wait: 0).and_return(true)
      expect(sender.execute).to be false
      expect(sender.status).to eq(:upload_timeout)
      expect(button).not_to have_received(:click)
    end

    it 'reports rejection without sending' do
      allow(composer).to receive(:has_selector?).with(attachment_error_css, wait: 0).and_return(true)
      expect(sender.execute).to be false
      expect(sender.status).to eq(:upload_rejected)
      expect(button).not_to have_received(:click)
    end

    it 'reports a missing upload input' do
      allow(composer).to receive(:find).with(video_input_css, visible: :all).and_raise(Capybara::ElementNotFound)
      expect(sender.execute).to be false
      expect(sender.status).to eq(:failed)
      expect(button).not_to have_received(:click)
    end

    it 'does not write or send when transfer fails' do
      allow(input).to receive(:set).and_raise(Selenium::WebDriver::Error::WebDriverError, 'upload failed')
      expect(sender.execute).to be false
      expect(field).not_to have_received(:send_keys)
      expect(button).not_to have_received(:click)
    end

    it 'prepares video without sending' do
      expect(sender.execute(send: false)).to be true
      expect(sender.status).to eq(:prepared)
      expect(button).not_to have_received(:click)
    end

    it 'rejects attachment-only semantics before navigation' do
      empty_sender = described_class.new(session, url, '', video: video)
      expect { empty_sender.execute }.to raise_error(ArgumentError, /non-empty text/)
      expect(session).not_to have_received(:visit)
    end

    it 'rejects oversized files before navigation' do
      allow(File).to receive(:size).with(video).and_return(described_class::MAX_VIDEO_BYTES + 1)
      expect { sender.execute }.to raise_error(described_class::InvalidVideo, /20 MB/)
      expect(session).not_to have_received(:visit)
    end

    it 'rejects unreadable files before navigation' do
      allow(File).to receive(:readable?).with(video).and_return(false)
      expect { sender.execute }.to raise_error(described_class::InvalidVideo, /readable/)
      expect(session).not_to have_received(:visit)
    end
  end

  it 'rejects missing files before navigation' do
    invalid = described_class.new(session, url, message, video: '/nonexistent/synthetic.mp4')
    expect { invalid.execute }.to raise_error(described_class::InvalidVideo)
    expect(session).not_to have_received(:visit)
  end

  it 'rejects unsupported extensions and empty files' do
    Tempfile.create(['video', '.avi']) do |file|
      file.write('fake'); file.flush
      invalid = described_class.new(session, url, message, video: file.path)
      expect { invalid.execute }.to raise_error(described_class::InvalidVideo, /MP4 and MOV/)
    end
    Tempfile.create(['empty', '.mov']) do |file|
      invalid = described_class.new(session, url, message, video: file.path)
      expect { invalid.execute }.to raise_error(described_class::InvalidVideo, /non-empty/)
    end
    expect(session).not_to have_received(:visit)
  end
end
