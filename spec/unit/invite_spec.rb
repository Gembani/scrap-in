require 'spec_helper'

RSpec.describe Salesnavot::Invite do
  include Tools
  let(:invite) do
    described_class.new(sales_nav_url, session, content)
  end

  let(:session) { instance_double('Capybara::Session') }
  let(:sales_nav_url) { 'sales_nav_url' }
  let(:content) { 'Message content' }

  let(:profile_css) { 'profile_css' }
  let(:degree_css) { 'degree_css' }
  let(:form_css) { 'form_css' }
  let(:form_email_css) { 'form_email_css' }
  let(:action_button_xpath) { 'action_button_xpath' }
  let(:connect_button_css) { 'connect_button_css' }
  let(:send_button_css) { 'send' }
  let(:pending_connection_css) { 'pending_connection_css' }
  let(:form_invitation_id) { '#form_invitation_id' }

  describe 'Initializer' do
    subject { described_class }
    it { is_expected.to eq Salesnavot::Invite }
  end

  describe 'instance of described class' do
    subject { invite.instance_variables }
    it { is_expected.to include(:@session) }
    it { is_expected.to include(:@error) }
    it { is_expected.to include(:@content) }
    it { is_expected.to include(:@sales_nav_url) }
  end

  describe '.execute' do
    context 'Lead was not found' do
      before do
        allow(session).to receive(:visit).with(sales_nav_url)
        allow(invite).to receive(:profile_css).and_return(profile_css)
        allow(session).to receive(:has_selector?).with(profile_css).and_return(false)
      end

      it 'raises an error' do
        expect do
          invite.execute
        end.to raise_error(css_error(profile_css))
      end
    end
    context 'The lead is already a friend' do
      before do
        allow(invite).to receive(:visit_target_page).with(sales_nav_url)
        allow(invite).to receive(:friend?).and_return(true)
        allow(invite).to receive(:initially_pending?).and_return(false)
        allow(invite).to receive(:action_button_xpath).and_return(action_button_xpath)
        allow(invite).to receive(:find_xpath_and_click).with(action_button_xpath)
      end

      it 'just writes an error!' do
        invite.execute
        expect(invite.error).not_to be_empty
      end
    end
    context 'when the email is required' do
      before do
        allow(invite).to receive(:visit_target_page).with(sales_nav_url)
        allow(invite).to receive(:friend?).and_return(false)
        allow(invite).to receive(:action_button_xpath).and_return(action_button_xpath)
        allow(invite).to receive(:connect_button_css).and_return(connect_button_css)
        allow(invite).to receive(:initially_pending?).and_return(false)
        allow(invite).to receive(:find_xpath_and_click).with(action_button_xpath)
        allow(invite).to receive(:find_and_click).with(connect_button_css)
        allow(invite).to receive(:lead_email_required?).and_return(true)
      end

      it 'just writes an error!' do
        invite.execute
        expect(invite.error).not_to be_empty
      end
    end

    context 'when the send button does not exist' do
      before do
        allow(invite).to receive(:visit_target_page).with(sales_nav_url)
        allow(invite).to receive(:initially_pending?).and_return(false)
        allow(invite).to receive(:action_button_xpath).and_return(action_button_xpath)
        allow(invite).to receive(:find_xpath_and_click).with(action_button_xpath)
        allow(invite).to receive(:friend?).and_return(false)
        allow(invite).to receive(:connect_button_css).and_return(connect_button_css)
        allow(invite).to receive(:find_and_click).with(connect_button_css)
        allow(invite).to receive(:lead_email_required?).and_return(false)
        allow(session).to receive(:fill_in).with(form_invitation_id, with: content).and_return(true)
        allow(invite).to receive(:send_button_css).and_return(send_button_css)
        allow(invite).to receive(:find_and_click).with(send_button_css).and_call_original
        allow(session).to receive(:has_selector?).with(send_button_css).and_return(false)
        allow(invite).to receive(:form_invitation_id).and_return(form_invitation_id)
      end

      it 'raises an error!' do
        expect do
          invite.execute
        end.to raise_error(css_error(send_button_css))
      end
    end
    context 'when send button was found' do
      before do
        allow(invite).to receive(:visit_target_page).with(sales_nav_url)
        allow(invite).to receive(:friend?).and_return(false)
        allow(invite).to receive(:click_and_connect).and_return(true)
      end
      context 'but the invitation button do not close' do
        before do
          allow(invite).to receive(:action_button_xpath).and_return(action_button_xpath)
          allow(invite).to receive(:find_xpath_and_click).with(action_button_xpath)
          allow(invite).to receive(:form_css).and_return(form_css)
          allow(session).to receive(:has_selector?).with(form_css).and_return(true)
          allow(invite).to receive(:initially_pending?).and_return(false)
        end
        it 'returns false!' do
          expect(invite.execute).to eq(false)
        end
        it 'writes an error!' do
          invite.execute
          expect(invite.error).not_to be_empty
        end
      end
      context 'but it cannot find again the action button' do
        before do
          allow(invite).to receive(:invitation_window_closed?).and_return(true)
          allow(invite).to receive(:action_button_xpath).and_return(action_button_xpath)
          allow(session).to receive(:has_selector?).with(:xpath, action_button_xpath).and_return(false)
          allow(invite).to receive(:initially_pending?).and_return(false)
        end
        it 'raises an error!' do
          expect do
            invite.execute
          end.to raise_error(css_error(action_button_xpath))
        end
      end
      context 'but it cannot find pending connection button' do
        before do
          allow(invite).to receive(:invitation_window_closed?).and_return(true)
          allow(invite).to receive(:action_button_xpath).and_return(action_button_xpath)
          allow(invite).to receive(:find_xpath_and_click).with(action_button_xpath)
          allow(invite).to receive(:pending_connection_css).and_return(pending_connection_css)
          allow(session).to receive(:has_selector?).with(pending_connection_css, {:wait=>4}).and_return(false)
        end
        it 'returns false!' do
          expect(invite.execute).to eq(false)
        end
        it 'writes an error!' do
          invite.execute
          expect(invite.error).not_to be_empty
        end
      end
    end
  end
end
