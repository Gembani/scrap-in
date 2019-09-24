# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScrapIn::LinkedIn::Messages do
  include CssSelectors::LinkedIn::Messages
  include ScrapIn::Tools

  let(:session) { instance_double('Capybara::Session') }
  let(:messages) { described_class.new(session, thread_link) }
  let(:thread_link) { 'Conversation url' }

  let(:messages_thread_array) { [] }
  before do
    allow(session).to receive(:visit).with(thread_link)
    create_node_array(messages_thread_array, 5, 'messages_thread_node')
  end
  context '' do
    it {messages.execute(0)}
  end
end