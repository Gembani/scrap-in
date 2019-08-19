# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::SalesNavMessages do
    include CssSelectors::SalesNavMessages

  let(:session) { instance_double('Capybara::Session') }

  before do
    # For more clear results without all the logs
    disable_puts_for_class(ScrapIn::SendInmail)
    visit_succeed(profile_url)
  end

  describe '.initialize' do
    it { is_expected.to eq ScrapIn::SendInmail }
  end


end