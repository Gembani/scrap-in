# LinkedIn video message adapter

This adapter has unit coverage and, after separate operator authorization,
supervised live draft/upload validation through both a supplied thread URL and a
supplied profile URL. It is **not ready for unattended production sending**:
live rejection/challenge handling and other UI variants still need validation.
One separately approved direct ScrapIn text+video send was performed via the
profile route. Its initial outcome was ambiguous because LinkedIn rendered a
native player; the revised confirmation check recognized that already-sent event
read-only using the saved pre-click snapshot. No duplicate send was performed.
Zendin end-to-end attachment sending is not implemented by this repository change.

## Public API

Existing text-only calls keep their positional arguments and boolean return:

```ruby
action = session.linkedin_send_message(confirmed_thread_url, approved_text)
sent = action.execute
```

Optional video (one file) uses keyword arguments:

```ruby
action = session.linkedin_send_message(
  confirmed_thread_url, approved_text,
  video: worker_local_video_path, upload_timeout: 120, confirmation_timeout: 10
)
prepared = action.execute(send: false) # draft only, no Send click
```

This is a call-signature example, not a standalone sender. Normal outbox execution
uses `execute` only after the caller's approvals/guard/pacing checks. Direct
`ScrapIn::LinkedIn::SendMessage.new(capybara, url, text, video: path)` also works.
Thread, compose-with-confirmed-recipient and supplied profile URLs remain supported.
A profile uses its own same-host Message destination when it provides a link;
button-only interfaces use the overlay, including the `#interop-outlet` shadow root.
The adapter does not search for names or verify recipient identity; the caller
must confirm the exact profile/thread. Visiting any thread may mark it read.
The Sales Navigator API/adapter is unchanged and does not gain video support.

Videos require non-empty text. Attachment-only messages raise `ArgumentError`
before navigation; they are deliberately unsupported. Preparation consumes the
action: calling `execute` again on it returns false. After a prepared draft,
human review/cleanup is required before a fresh outbox operation, which refuses
an existing text or attachment draft. Do not clear a draft automatically.

## Validation and transfer

Before any navigation, files must be readable, non-empty regular files, have an
MP4 or MOV extension (case insensitive), and be at most 20,000,000 bytes. This is
a conservative decimal interpretation of LinkedIn's messaging limit. Invalid
files raise `ScrapIn::LinkedIn::SendMessage::InvalidVideo < ArgumentError`.
The validation checks extension/size/readability, not container codecs, duration,
resolution or media integrity; LinkedIn can still reject an invalid video.
No transcoding, copying back, or modification of the original is performed.

[LinkedIn Messaging help](https://www.linkedin.com/help/linkedin/answer/a567264)
(accessed 2026-10-04) explicitly lists MP4/MOV and attachments up to 20 MB.
Feed, advertising and Videos API limits are not applicable to messaging.
No separate messaging codec/duration limit is assumed.

The path is local to the **Ruby worker**, not necessarily to the operator's host.
For Docker, stage/mount an approved asset into the `scrapin` container and use its
container path. A host Downloads path is not automatically visible there.
The existing remote Capybara driver is sufficient: Capybara's file-input `set`
scopes Selenium file detection, uploads bytes through `/session/:id/se/file`,
and sends the resulting remote path to Chrome. No browser volume or dependency
is added. [Selenium Ruby file detection documentation](https://www.selenium.dev/selenium/docs/api/rb/Selenium/WebDriver/DriverExtensions/UploadsFiles.html).
The unit transport test exercises the installed Capybara/Selenium implementation
with a fake upload endpoint and inspects the zipped bytes/server path.

## Send and failure semantics

The composer and message list must belong to the same conversation container.
The adapter refuses an existing draft, attaches first, waits for completion,
writes approved text, verifies attachment readiness again and checks that Send
is enabled. Upload rejection, transfer failure, missing UI and timeout stop
before clicking Send; no fallback sends text without its video. A failed
operation may leave a partial draft which requires human inspection/cleanup.

`execute` returns true only for `status == :sent` (or `:prepared` with
`send: false`). Inspect `status` and `error` when false:

| Status | Meaning/action |
| --- | --- |
| `:authentication_required` | Login/checkpoint/authwall detected; human intervention required. |
| `:unavailable` | Recipient composer did not appear. |
| `:draft_not_empty` | Existing draft requires human review. |
| `:upload_rejected` | Attachment error displayed. |
| `:upload_timeout` | Upload/processing completion not established. |
| `:not_ready` | Send disabled/missing or attachment lost readiness. |
| `:confirmation_unavailable` | Existing message events lack stable identity; no Send click. |
| `:failed` | Browser/file operation failed before Send was attempted; see error. |
| `:ambiguous` | Send was attempted but not confirmed, including transport errors. Inspect thread before any retry. |

The sole Send click is never retried. Reusing an executed action cannot click
again. This is not cross-process idempotency: an outbox must persist attempt and
outcome, and hold ambiguous operations for review instead of constructing a new
action automatically. An ambiguous outcome does not prove delivery or failure.
Login/challenge redirects after a click are ambiguous, too.

Confirmation snapshots stable event URNs immediately before Send and requires
a new outgoing event with the exact text and LinkedIn's explicit sent
acknowledgement on its text bubble. Video confirmation additionally requires
an acknowledged filename-bearing attachment link or exactly one sourced native
video player in that same event, with a sent indicator on its own bubble. An old identical
body, a DOM rerender with the same event URN, a new incoming message, or a new
text-only event cannot confirm text+video. `thread_url` is populated on confirmed
success only when navigation exposes a `/messaging/thread/` URL. LinkedIn's native player does not display the original filename. Native-player
confirmation relies on the previously validated single-video upload, exact text,
fresh outgoing event URN and media-bubble acknowledgement; it does not verify a
media hash. This verifies UI acknowledgement, not recipient playback/delivery. Worker
exclusivity is required to prevent another sender producing a competing event.

## Unverified DOM contract and supervised validation

The following selectors in `css_selectors/linkedin/send_message.rb` were observed
in the supervised browser on 2026-10-04: the video-capable file input (distinct
from the image-only input), `.msg-form__attachment-preview`, its filename heading,
its explicit `data-test-msg-cross-pillar-uploaded-attachments-list__attached`
marker, upload progress and `--uploading` state, and composer ancestry. Historical
message events expose URNs on their inner `.msg-s-event-listitem`, and incoming
events carry `--other`; outgoing events omit that class. These observations are
covered by sanitized synthetic unit DOM, without committing recipient or message
history data. Missing explicit completion evidence still times out safely.
A progress bar at 100% was observed while the file was still processing; it is
not completion evidence.

Profile Message links were observed without aria-labels. The adapter follows the
profile's own same-host messaging href to avoid an inconsistent React/Ember
overlay startup. When a button opens an overlay, composer discovery also supports
the observed `#interop-outlet` shadow root. The overlay discovery has unit coverage;
the successful live profile upload used the direct Message destination.

**Unverified live:** rejection/error and alternate processing markers,
login/challenge interruption during upload/send, attachment-only sending
(unsupported), and other LinkedIn UI variants. The sent-attachment filename-link
selector remains provisional; native-player markup and sent acknowledgement were
observed on the single authorized send and checked with the revised predicate. DOM changes or localization
can cause a conservative failure/ambiguous result. Do not weaken readiness to
elapsed time, preview presence alone or an enabled button.

Later validation, requiring separate human authorization:

1. Confirm an exact consenting test profile/thread, permission to open it, and a
   reviewed message plus small MP4/MOV. Do not resolve a recipient by name alone.
2. Acquire Zendin's exclusive browser worker; use the existing single-session
   Docker Chrome and human takeover at `http://localhost:7900`. Stage the asset
   in the Ruby container; record its checksum and ensure approval covers it.
3. Under supervision inspect the composer/history DOM in that exact thread.
   Verify/scopingly adjust selectors using actual completion, rejection and
   processing evidence. Capture sanitized DOM fixtures and update unit tests.
4. Through an authorized outbox preparation path use `execute(send: false)`.
   Observe remote transfer, processing completion and filename/preview without
   clicking Send. Check rejected and slow uploads stop without sending. Have a
   human remove prepared/failed drafts; verify the source checksum is unchanged.
5. Only after Zendin attachment wiring and separate approval, enqueue one test
   send through its normal outbox, guard and pacing. Observe a new stable outgoing
   event containing the approved text and video. Verify recipient/playback and
   compare adapter outcome. A duplicate text test must confirm only the new event.
6. If confirmation/transport is uncertain, hold the queue entry for human thread
   reconciliation. Never auto-retry. Do not run live integration specs casually:
   the existing send-message integration tests actually send messages.

The initial implementation used no live browser. In a later operator-authorized
validation, the supplied thread and profile were opened and text+video drafts
prepared with `execute(send: false)`. Both returned `:prepared`, with the explicit
attached marker and Send enabled. Only drafts created by that test were cleaned
between routes; the final profile-route draft was left visible for the operator.
The source checksum matched before and after the uploads. The operator then
explicitly replaced the outbox-only constraint for one direct supervised ScrapIn
send of the reviewed text and video. The test-owned draft was cleared first, and
the normal `execute` path attached the video and clicked Send once via the profile
route. LinkedIn showed the new outgoing text plus native video with sent indicators
and cleared the composer. The initial adapter result was `:ambiguous`; inspection
established why (no filename link), then the revised `message_sent?` returned true
against the original pre-click URNs. No second message was sent to retest the fix.
The source SHA-256 remained unchanged. Future Zendin sending still requires its
attachment/outbox wiring; the one-off authorization does not implement it.

## Required Zendin follow-up (outside this change)

Zendin must own attachment storage and immutable asset references/checksums,
access controls, worker-local staging and retention/cleanup; serialize the asset
reference with `QueuedMessage` rather than assuming an operator absolute path.
Review must display/play the exact video alongside all message words, record
approval for both, and invalidate approval if either changes. Resolve confirmed
profile/thread identity before enqueueing. Extend the worker call with
`linkedin_send_message(confirmed_url, approved_text, video: staged_path)` while
retaining `Outreach::Guard`, pacing and exclusive browser ownership. Persist
attempt state and status/error, distinguish prepared from sent, and hold
ambiguous results for reconciliation. Preserve optional Sales Navigator routing
without passing unsupported video keywords to that adapter. ScrapIn does not
provide approvals, a queue, identity resolution or a sending script.

## Verification recorded for this change

Before edits, `docker compose run --rm --no-deps -T scrapin bundle exec rspec
spec/unit` produced 288 examples, 2 failures, 5 pending. After edits the same
command produced 315 examples, 2 failures, 5 pending. After supervised DOM
refinements it produced 318 examples, 2 failures, 5 pending; after the live-send
confirmation fix it produced 321 examples, 2 failures, 5 pending. Both failures are unchanged
Sales Navigator `ScrapThreads` cases (`spec/unit/sales_navigator/scrap_threads_spec.rb`
lines 94 and 116), caused by missing mock expectations for the lead-name selector.

Focused verification:

```sh
docker compose run --rm --no-deps -T scrapin bundle exec rspec \
  spec/unit/linkedin/send_message_spec.rb \
  spec/unit/linkedin/video_transfer_spec.rb spec/unit/session_spec.rb
```

Initial result: 73 examples, 0 failures. After the live DOM refinements, the
focused command produced 76 examples, 0 failures. After the sent-player and
acknowledgement refinements it produced 79 examples, 0 failures. `git diff --check` also passed.
All unit test assets
were synthetic temporary files. No sending integration specs were run and no
production service was restarted. The separate supervised draft validation used
the existing Zendin Docker browser/profile and the operator-supplied video,
mounted read-only in the Ruby worker. Docker emits a non-fatal gemspec
`git` warning because this worktree's host git metadata path is outside the `/app`
mount; the specs still execute. Changes are left uncommitted for operator review.
