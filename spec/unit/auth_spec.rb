require 'spec_helper'

RSpec.describe ScrapIn::Auth do
  let(:auth) do
    described_class.new(session)
  end

  let(:session) { instance_double('Capybara::Session') }
  let(:username) { 'username' }
  let(:password) { 'password' }
  let(:linkedin_homepage) { 'linkedin_homepage' }
  let(:sales_navigator_homepage) { 'sales_navigator_homepage' }
  include CssSelectors::Auth

  describe 'Initializer' do
    subject { described_class }
    it { is_expected.to eq ScrapIn::Auth }
  end

  describe 'instance of described class' do
    subject { auth.instance_variables }
    it { is_expected.to include(:@session) }
  end

  describe '.login' do
    before do
      allow(auth).to receive(:linkedin_homepage).and_return(linkedin_homepage)
      allow(auth).to receive(:sales_navigator_homepage).and_return(sales_navigator_homepage)

      allow(session).to receive(:visit)
      allow(session).to receive(:current_url).with(no_args).and_return("www.test.com")
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
      has_not_selector(session, security_check_css) # There is no captcha verification
    end

    context 'when we log in into sales navigator' do
      before { has_field(session, placeholder: sales_navigator_placeholder, wait: 1) }

      context 'when all css were found' do
        context 'when the credentials are correct' do
          it 'should work and call the right methods for sales navigator' do
            expect(auth).to receive(:search_placeholder).and_return(sales_navigator_placeholder)
            expect(auth).to receive(:homepage).and_return(sales_navigator_homepage)
            auth.login!(username, password)
          end
        end
        context 'when the credentials are incorrect' do
          before { has_selector(session, password_error_css, wait: 1) }
          it { expect { auth.login!(username, password) }.to raise_error(ScrapIn::IncorrectPassword) }
        end
        context 'when it cannot find the sales navigator search placeholder' do
          before { has_not_field(session, placeholder: sales_navigator_placeholder, wait: 1) }
          it { expect { auth.login!(username, password) }.to raise_error(ScrapIn::CssNotFound) }
        end
      end
    end

    context 'when we log in into linkedin' do
      before { has_field(session, placeholder: linkedin_placeholder, wait: 1) }

      context 'when all css were found' do
        it 'should work and call the right methods for linkedin' do
          expect(auth).to receive(:search_placeholder).and_return(linkedin_placeholder)
          expect(auth).to receive(:homepage).and_return(linkedin_homepage)
          auth.login!(username, password, true)
        end

        context 'when the credentials are incorrect' do
          before { has_selector(session, password_error_css, wait: 1) }
          it { expect { auth.login!(username, password, true) }.to raise_error(ScrapIn::IncorrectPassword) }
        end

        context 'when it cannot find the sales navigator search placeholder' do
          before { has_not_field(session, placeholder: linkedin_placeholder, wait: 1) }
          it { expect { auth.login!(username, password, true) }.to raise_error(ScrapIn::CssNotFound) }
        end
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
  end
end
