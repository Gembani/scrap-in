require 'spec_helper'

RSpec.describe Salesnavot::Auth do
  let(:auth) do
    described_class.new(session)
  end

  let(:session) { instance_double('Capybara::Session') }
  let(:login_button) { 'login_button_css' }
  let(:email_input) { 'email_css' }
  let(:username) { 'username' }
  let(:password_input) { 'password_css' }
  let(:password) { 'password' }
  let(:insight_list_css) { 'insight_list_css' }

  describe 'Initializer' do
    subject { described_class }
    it { is_expected.to eq Salesnavot::Auth }
  end

  describe 'instance of described class' do
    subject { auth.instance_variables }
    it { is_expected.to include(:@session) }
  end

  describe '.login' do
    before do
      allow(auth).to receive(:email_input).and_return(email_input)
      allow(auth).to receive(:password_input).and_return(password_input)
      allow(auth).to receive(:login_button).and_return(login_button)
      allow(auth).to receive(:insight_list_css).and_return(insight_list_css)
      allow(session).to receive(:visit).with(auth.homepage)
      allow(session).to receive(:fill_in).with(id: email_input, with: username)
      allow(session).to receive(:fill_in).with(id: password_input, with: password)
    end
    context 'Username and password are correct' do
      before do
        allow(session).to receive_message_chain(:find, :click).and_return(true)
        allow(session).to receive(:has_selector?).with(insight_list_css).and_return(true)
      end

      it 'logs in into Linkedin' do
        auth.login!(username, password)
        expect(auth).to have_received(:email_input)
        expect(auth).to have_received(:password_input)
        expect(auth).to have_received(:login_button)
        expect(auth).to have_received(:insight_list_css)
        expect(session).to have_received(:visit).with(auth.homepage)
        expect(session).to have_received(:fill_in).with(id: email_input, with: username)
        expect(session).to have_received(:fill_in).with(id: password_input, with: password)
        expect(session.find.click).to eq(true)
        expect(session).to have_received(:has_selector?).with(insight_list_css)
      end
    end
    context 'Username and/or password are incorrect' do
      before do
        allow(session).to receive_message_chain(:find, :click).and_return(true)
        allow(session).to receive(:has_selector?).with(insight_list_css).and_return(false)
      end

      it 'does not log in into Linkedin and raises an error' do
        expect do
          auth.login!(username, password)
        end.to raise_error('Login failed !')
      end
    end
  end
end
