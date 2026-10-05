require 'uri'

module ScrapIn
  module LinkedIn
    # One browser action. Queueing, approvals and worker exclusivity belong to the caller.
    class SendMessage
      include Tools
      include CssSelectors::LinkedIn::SendMessage

      MAX_VIDEO_BYTES = 20_000_000 # LinkedIn Messaging help: up to 20 MB (conservative decimal MB).
      class InvalidVideo < ArgumentError; end

      attr_reader :thread_url, :status, :error

      def initialize(session, thread, message, video: nil, upload_timeout: 120, confirmation_timeout: 10, ready_timeout: 5)
        @session, @thread, @message = session, thread, message
        @video = video
        @upload_timeout = Integer(upload_timeout)
        @confirmation_timeout = Integer(confirmation_timeout)
        @ready_timeout = Integer(ready_timeout)
        raise ArgumentError, 'Timeouts must be positive seconds' unless [@upload_timeout, @confirmation_timeout, @ready_timeout].all?(&:positive?)
        @status = :pending
      end

      # false means inspect status/error; :ambiguous must never be automatically retried.
      # send: false prepares the draft for supervised inspection without clicking Send.
      def execute(send: true)
        return false unless @status == :pending

        validate_video! if @video
        if @video && @message.to_s.strip.empty?
          raise ArgumentError, 'Video messages require non-empty text; attachment-only messages are not supported'
        end
        return fail_with(:authentication_required, 'Login or challenge requires human attention') if authentication_required?
        unless visit_profile
          return fail_with(:authentication_required, 'Login or challenge requires human attention') if authentication_required?
          return fail_with(:unavailable, 'Recipient messaging UI is unavailable')
        end
        return fail_with(:authentication_required, 'Login or challenge requires human attention') if authentication_required?

        @composer = @message_scope.find(message_field_css).find(:xpath, 'ancestor::form[1]')
        @conversation = @composer.find(:xpath, conversation_xpath)
        return fail_with(:draft_not_empty, 'Existing draft text or attachments require human review') unless draft_empty?

        return false if @video && !attach_video
        write_message
        # LinkedIn enables Send a moment after it has taken in the typed text
        return fail_with(:not_ready, 'Send button is unavailable or disabled') unless try_until_true(@ready_timeout * 4, 0.25) { ready_to_send? }
        unless send
          @status = :prepared
          return true
        end

        # Snapshot immediately before the sole click, never by matching an old last body.
        native_send_button = @composer.find(send_button_css).native
        @before_ids = events.map { |event| event_id(event) }
        return fail_with(:confirmation_unavailable, 'Existing message events have no stable identity') if @before_ids.any?(&:empty?)
        return fail_with(:authentication_required, 'Login or challenge requires human attention') if authentication_required?
        @click_attempted = true
        # Avoid Capybara's stale-element action retries for this non-idempotent click.
        native_send_button.click
        if try_until_true(@confirmation_timeout, 1) { confirmation_settled? }
          @status = :sent
          @thread_url = current_thread_url
          true
        else
          fail_with(:ambiguous, 'Send was attempted but a new outgoing message with the requested content was not confirmed; inspect the thread before retrying')
        end
      rescue ScrapIn::CssNotFound, Capybara::CapybaraError, Selenium::WebDriver::Error::WebDriverError, IOError, SystemCallError => e
        fail_with(@click_attempted ? :ambiguous : :failed, "#{e.class}: #{e.message}")
      end

      def visit_profile
        @session.visit(@thread)
        return false if authentication_required?
        open_message_overlay if profile_url?
        try_until_true(10, 1) do
          @message_scope = find_message_scope
          !@message_scope.nil?
        end
      end

      def profile_url?
        @thread.include?('linkedin.com/in/')
      end

      def open_message_overlay
        card = check_and_find(@session, profile_top_card_css, wait: 10)
        button = check_and_find_first(card, profile_message_button_css, wait: 5)
        href = button['href']
        if href && !href.empty?
          current = URI.parse(@session.current_url)
          destination = URI.join(current.to_s, href)
          unless destination.host == current.host && destination.path.start_with?('/messaging/')
            raise ScrapIn::CssNotFound, 'Expected a same-host LinkedIn messaging destination'
          end
          # Following the profile's own link avoids racing React/Ember overlay startup.
          @session.visit(destination.to_s)
        else
          button.click
        end
      end

      def current_thread_url
        url = @session.current_url
        url if url.include?(thread_path)
      end

      def write_message
        @composer.find(message_field_css).send_keys(@message)
      end

      def message_sent?
        return false unless @before_ids && !authentication_required?
        events.any? do |event|
          id = event_id(event)
          next false if id.empty? || @before_ids.include?(id)
          next false unless event.has_selector?(outgoing_event_css, wait: 0)
          bodies = event.all(messages_css, wait: 0)
          next false unless bodies.any? && bodies.map(&:text).join("\n") == @message
          bodies.all? { |body| acknowledged?(body) } && (!@video || sent_video?(event))
        end
      end

      private

      # After the click LinkedIn replaces the optimistic event with the server
      # copy, and re-renders it again when a link preview card arrives.
      # A node detached mid-check means "not yet", so keep polling.
      def confirmation_settled?
        message_sent?
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        false
      end

      def find_message_scope
        return @session if @session.has_selector?(message_field_css, wait: 0)
        return nil unless @session.has_selector?(messaging_shadow_host_css, wait: 0)

        root = @session.find(messaging_shadow_host_css).shadow_root
        root if root && root.has_selector?(message_field_css, wait: 0)
      end

      def fail_with(status, error)
        @status, @error = status, error
        false
      end

      def validate_video!
        unless @video.is_a?(String) && File.file?(@video) && File.readable?(@video)
          raise InvalidVideo, 'Video must be a readable regular file local to the Ruby process'
        end
        @video = File.expand_path(@video)
        unless %w[.mp4 .mov].include?(File.extname(@video).downcase)
          raise InvalidVideo, 'LinkedIn Messaging video attachments support MP4 and MOV'
        end
        size = File.size(@video)
        raise InvalidVideo, 'Video must be non-empty and at most 20 MB' unless size.positive? && size <= MAX_VIDEO_BYTES
        # Extension is not codec validation. LinkedIn still decides whether the media is valid.
        File.open(@video, 'rb') { |file| file.read(1) }
      end

      def authentication_required?
        @session.current_url.to_s.match?(%r{/(login|checkpoint|authwall|uas/login)(/|\?|$)})
      end

      def draft_empty?
        @composer.find(message_field_css).text.strip.empty? &&
          !@composer.has_selector?(attachment_preview_css, wait: 0)
      end

      def attach_video
        input = @composer.find(video_input_css, visible: :all)
        # Capybara's file input setter scopes Selenium's file detector and transfers
        # local bytes through /se/file when the registered driver is remote.
        input.set(@video)
        @video_ready = false
        ready = try_until_true(@upload_timeout, 1) do
          break false if authentication_required? || upload_rejected?
          @video_ready = upload_ready?
        end
        return fail_with(:authentication_required, 'Login or challenge interrupted upload') if authentication_required?
        return fail_with(:upload_rejected, 'LinkedIn rejected the attachment; inspect the composer') if upload_rejected?
        return fail_with(:upload_timeout, 'Video upload/processing did not become ready; no message sent') unless ready
        true
      end

      def upload_rejected?
        @composer.has_selector?(attachment_error_css, wait: 0)
      end

      def upload_ready?
        previews = @composer.all(attachment_preview_css, wait: 0)
        return false unless previews.size == 1
        name = previews.first.first(attachment_name_css, minimum: 0, wait: 0)
        name && name.text.strip == File.basename(@video) &&
          previews.first.has_selector?(attachment_ready_css, wait: 0) &&
          !@composer.has_selector?(attachment_busy_css, wait: 0)
      end

      def ready_to_send?
        return false if authentication_required?
        return false if @video && (!@video_ready || upload_rejected? || !upload_ready?)
        button = @composer.first(send_button_css, minimum: 0, wait: 0)
        button && !button.disabled? && button['aria-disabled'] != 'true'
      end

      # LinkedIn may redraw the whole conversation after a send (seen on a first message in a conversation): the
      # box found before the click is then gone for good, so look it up again from the composer
      def events
        @conversation.all(message_events_css, wait: 0)
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        raise unless @click_attempted && (redrawn = current_conversation)

        @conversation = redrawn
        @conversation.all(message_events_css, wait: 0)
      end

      def current_conversation
        scope = find_message_scope
        return nil unless scope

        scope.find(message_field_css).find(:xpath, 'ancestor::form[1]').find(:xpath, conversation_xpath)
      rescue Capybara::ElementNotFound
        nil
      end

      def event_id(event)
        urn = event['data-event-urn']
        urn ||= event.first(event_identity_css, minimum: 0, wait: 0)&.[]('data-event-urn')
        urn.to_s
      end

      def acknowledged?(node)
        container = node.first(:xpath, sent_container_xpath, minimum: 0, wait: 0)
        container && container.has_selector?(sent_indicator_css, wait: 0)
      end

      def sent_video?(event)
        file_link = event.all(sent_attachment_css, wait: 0).any? do |attachment|
          attachment.text.strip == File.basename(@video) && !attachment['href'].to_s.empty? && acknowledged?(attachment)
        end
        return true if file_link

        # LinkedIn renders MP4 as a native player without the filename. The sole
        # requested video must be in the same new outgoing event and acknowledged.
        videos = event.all(sent_video_css, wait: 0)
        videos.size == 1 && !videos.first['src'].to_s.empty? && acknowledged?(videos.first)
      end
    end
  end
end
