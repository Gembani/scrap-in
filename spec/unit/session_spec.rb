require 'spec_helper'

RSpec.describe ScrapIn::Session do


  let(:username) { 'username' }
  let(:password) { 'password' }
  let(:driver) { 'driver' }

  [true, false].each do |linkedin|
    describe '.intialize' do
      let(:capybara_session) { instance_double('Capybara::Session') }
      let(:auth) { instance_double('ScrapIn::Auth') }
      platform_name = linkedin ? 'linkedin' : 'sales navigator'

      context "when we want to log into #{platform_name}" do
        before do
          allow(ENV).to receive(:fetch).with('driver').and_return(driver)
          allow(Capybara::Session).to receive(:new).with(driver.to_sym).and_return(capybara_session)
          allow(auth).to receive(:login!).with(username, password, linkedin)
          allow(ScrapIn::Auth).to receive(:new).with(capybara_session).and_return(auth)
        end
        after do
          ScrapIn::Session.new(username, password, linkedin)
        end
        it 'should have created a new session' do
          expect(Capybara::Session).to receive(:new).with(driver.to_sym).and_return(capybara_session)
        end
        it "should have logged in into #{platform_name}" do
          expect(ScrapIn::Auth).to receive(:new).with(capybara_session).and_return(auth)
          expect(auth).to receive(:login!).with(username, password, linkedin)
        end
      end
    end

    # describe '.scrap_lead' do
    #   let(:scrap_lead) { instance_double('ScrapIn::Scrap') }
    #   before do
    #     allow(ScrapIn::ScrapLead).to receive(:new).and_return
    #   end
    # end
  end
end

