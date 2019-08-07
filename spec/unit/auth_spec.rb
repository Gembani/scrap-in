require 'spec_helper'

RSpec.describe ScrapIn::SalesNavigator::Auth do
  let(:auth) do
    described_class.new(session)
  end

  let(:session) { instance_double('Capybara::Session') }
  let(:email_input) { 'email_css' }
  let(:username) { 'username' }
  let(:password_input) { 'password_css' }
  let(:password) { 'password' }
  let(:alert_header_css) { 'alert_header_css' }
  let(:captcha_css) {'captcha_css'}

  describe 'Initializer' do
    subject { described_class }
    it { is_expected.to eq ScrapIn::SalesNavigator::Auth }
  end

  describe 'instance of described class' do
    subject { auth.instance_variables }
    it { is_expected.to include(:@session) }
  end

  describe '.login' do
    before do
      allow(auth).to receive(:email_input).and_return(email_input)
      allow(auth).to receive(:password_input).and_return(password_input)
      allow(auth).to receive(:captcha_css).and_return(captcha_css)
      allow(auth).to receive(:alert_header_css).and_return(alert_header_css)
      allow(auth).to receive(:username).and_return(username)
      allow(auth).to receive(:password).and_return(password)
      allow(session).to receive(:visit).with(auth.homepage)
      allow(session).to receive(:has_selector?).with(email_input).and_return(true)
    end
    context 'Username and password are correct' do
      before do
        allow(session).to receive_message_chain(:find, :click).and_return(true)
        allow(session).to receive_message_chain(:find, :send_keys).and_return(true)
        allow(session).to receive(:has_selector?).with('#error-for-username').and_return(false)
      end
      context 'when a CAPTCHA page appears' do
        before do
          allow(session).to receive(:has_selector?).with(captcha_css).and_return(true)
        end
        xit 'raises an error' do
          expect do
            auth.login!(username, password)
          end.to raise_error(CaptchaError)
        end
      end
      context 'when CAPTCHA didnt appear' do
        before do
          allow(session).to receive(:has_selector?).with(captcha_css).and_return(false)
          allow(session).to receive(:has_selector?).with(alert_header_css).and_return(true)
        end
        xit 'logs in into Linkedin' do
          auth.login!(username, password)
          expect(auth).to have_received(:email_input).twice
          expect(auth).to have_received(:password_input)
          expect(auth).to have_received(:alert_header_css)
          expect(session).to have_received(:visit).with(auth.homepage)
          expect(session.find.click).to eq(true)
          expect(session).to have_received(:has_selector?).with(alert_header_css)
        end
      end
    end
    context 'Username and/or password are incorrect' do
      before do
        allow(session).to receive_message_chain(:find, :click).and_return(true)
        allow(session).to receive_message_chain(:find, :send_keys).and_return(true)
        allow(session).to receive(:has_selector?).with('#error-for-username').and_return(false)
        allow(session).to receive(:has_selector?).with(captcha_css).and_return(false)
        allow(session).to receive(:has_selector?).with(alert_header_css).and_return(false)
      end

      xit 'does not log in into Linkedin and raises an error' do
        expect do
          auth.login!(username, password)
        end.to raise_error('Login failed !')
      end
    end
  end
end
