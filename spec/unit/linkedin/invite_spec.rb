# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::Invite do
	let(:subject) do
		described_class
	end

	let(:invite_instance) do
		subject.new(session)
	end

	describe '.execute' do
		context 'try it' do
			it 'should do something' do
				expect(0).to eq(0)
			end
		end
	end
end