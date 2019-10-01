require 'spec_helper'

RSpec.describe ScrapIn::SalesNavigator::Auth do
  let(:auth) do
    described_class.new(session)
  end

  let(:session) { instance_double('Capybara::Session') }
  let(:username) { 'username' }
  let(:password) { 'password' }
  include CssSelectors::SalesNavigator::Auth

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
      allow(session).to receive(:visit)
      username_field = instance_double('Capybara::Node::Element', 'username_field')
      allow(username_field).to receive(:click)
      allow(username_field).to receive(:send_keys).with(username)
      has_selector(session, username_input_css)
      allow(session).to receive(:find).with(username_input_css).and_return(username_field)

      password_field = instance_double('Capybara::Node::Element', 'password_field')
      allow(password_field).to receive(:click)
      allow(password_field).to receive(:send_keys).with(password)
      allow(password_field).to receive(:send_keys).with(:enter)
      has_selector(session, password_input_css)
      allow(session).to receive(:find).with(password_input_css).and_return(password_field)

      has_not_selector(session, password_error_css, wait: 1)
      has_selector(session, alert_header_css)
    end

    context 'when all css were found' do
      it 'should work' do
        auth.login!(username, password)
      end

      context 'when the credentials are incorrect' do
        before { has_selector(session, password_error_css, wait: 1) }
        it { expect { auth.login!(username, password) }.to raise_error(ScrapIn::IncorrectPassword) }
      end
    end

    context 'when it cannot find the username input css' do
      before { has_not_selector(session, username_input_css) }
      it { expect { auth.login!(username, password) }.to raise_error(ScrapIn::CssNotFound) }
    end

    context 'when it cannot find the password input css' do
      before { has_not_selector(session, password_input_css) }
      it { expect { auth.login!(username, password) }.to raise_error(ScrapIn::CssNotFound) }
    end

    context 'when it cannot find the alert css' do
      before { has_not_selector(session, alert_header_css) }
      it { expect { auth.login!(username, password) }.to raise_error(ScrapIn::CssNotFound) }
    end
  end
end
