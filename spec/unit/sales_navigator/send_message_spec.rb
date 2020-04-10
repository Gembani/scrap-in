require 'spec_helper'

RSpec.describe ScrapIn::SalesNavigator::SendMessage do
  include CssSelectors::SalesNavigator::SendMessageThread
  include CssSelectors::SalesNavigator::SendMessageProfile
  
  include ScrapIn::Tools

  let(:subject) { described_class }
  
  let(:session) { instance_double('Capybara::Session', 'session') }
  let(:thread_url) { 'https://www.linkedin.com/sales/inbox/6572101845743910912' }
  let(:profile_url) { 'https://www.linkedin.com/sales/people/6572101845743910912' }
  let(:profile_url_2) { 'https://www.linkedin.com/sales/profile/264165374,vjcr,NAME_SEARCH' }

  let(:not_compatible_url) { 'https://www.linkedin.com/asfas' }
  
  
  
  let(:message) { 'Message to send to lead' }

  let(:messages_array) { [] }

  let(:conversation_array) { [] }

  let(:message_field_node) { instance_double('Capybara::Node::Element', 'message_field_node') }
  let(:button_node) { instance_double('Capybara::Node::Element', 'button_node') }

  let(:new_node) { instance_double('Capybara::Node::Element', 'new_node') }
  context 'when incompatible url' do 
    let(:url) { 'www.google' }

    it {
      expect { described_class.new(session, url, message) }.to raise_error(ArgumentError)
    }
  end
  context 'when using profile url' do 
    let(:profile_send_node) do
      node = instance_double('Capybara::Node::Element', 'profile_send_node')
      allow(node).to receive(:click).with(no_args)
      node
    end
    let(:text_area_node) do
      node = instance_double('Capybara::Node::Element', 'text_area_node')
      allow(node).to receive(:send_keys).with(message)
      node
    end
    let(:profile_send_message_button_node) do
      node = instance_double('Capybara::Node::Element', 'profile_send_message_button')
      allow(node).to receive(:click).with(no_args)
      node
    end
    
    
    let(:salesnav_messages_instance) { subject.new(session, profile_url, message) }
    
    before do 
      allow(session).to receive(:current_url).with(no_args).and_return('www.google.com')
      allow(session).to receive(:visit).with(profile_url)
      has_selector(session, profile_send_button)
      find(session, profile_send_node, profile_send_button)
      has_selector(session, 'textarea')
      find(session, text_area_node, 'textarea')
      has_selector(session, profile_send_message_button)
      find(session, profile_send_message_button_node, profile_send_message_button)
      expect(salesnav_messages_instance.execute).to eq(true)
    end
    
    it {
      expect(profile_send_node).to have_received(:click)
    }
 
    it {
      expect(profile_send_message_button_node).to have_received(:click)
    }
 
    it {
      expect(text_area_node).to have_received(:send_keys)
    }
 
  end

  context 'when using profile url 2' do 
    let(:profile_send_node) do
      node = instance_double('Capybara::Node::Element', 'profile_send_node')
      allow(node).to receive(:click).with(no_args)
      node
    end
    let(:text_area_node) do
      node = instance_double('Capybara::Node::Element', 'text_area_node')
      allow(node).to receive(:send_keys).with(message)
      node
    end
    let(:profile_send_message_button_node) do
      node = instance_double('Capybara::Node::Element', 'profile_send_message_button')
      allow(node).to receive(:click).with(no_args)
      node
    end
    
    
    let(:salesnav_messages_instance) { subject.new(session, profile_url_2, message) }
    
    before do 
      allow(session).to receive(:current_url).with(no_args).and_return('www.google.com')
      allow(session).to receive(:visit).with(profile_url_2)
      has_selector(session, profile_send_button)
      find(session, profile_send_node, profile_send_button)
      has_selector(session, 'textarea')
      find(session, text_area_node, 'textarea')
      has_selector(session, profile_send_message_button)
      find(session, profile_send_message_button_node, profile_send_message_button)
      expect(salesnav_messages_instance.execute).to eq(true)
    end
    
    it {
      expect(profile_send_node).to have_received(:click)
    }
 
    it {
      expect(profile_send_message_button_node).to have_received(:click)
    }
 
    it {
      expect(text_area_node).to have_received(:send_keys)
    }
 
  end
  context 'when using thread url' do 
    let(:salesnav_messages_instance) { subject.new(session, thread_url, message) }
    before do
      disable_puts
      allow(session).to receive(:visit)
      allow(session).to receive(:current_url).with(no_args).and_return('testtests')
      10.times { messages_array << Faker::Lorem.unique.sentence }
      has_selector(session, messages_css)
      allow(session).to receive(:all).with(messages_css).and_return(conversation_array)
      create_node_array(conversation_array, messages_array.length, 'conversation_node')

      has_selector(session, message_field_css)
      find(session, message_field_node, message_field_css)
      allow(message_field_node).to receive(:send_keys).with(message).and_return(conversation_array << new_node)

      conversation_array.each_with_index do |conversation, index|
        allow(conversation).to receive(:text).and_return(messages_array[index])
      end
      allow(new_node).to receive(:text).and_return(message)

      has_selector(session, send_button_css)
      find(session, button_node, send_button_css)
      allow(button_node).to receive(:click).and_return(true)
    end
    
    context 'when cannot load conversation' do
      context 'when fails to load' do
        before { allow(session).to receive(:all).with(messages_css).and_return([]) }
        it { expect(salesnav_messages_instance.execute).to eq(false) }
      end

      context 'when cannot find messages_css' do
        before do
          has_not_selector(session, messages_css)
          allow(session).to receive(:all).with(messages_css).and_return([])
        end
        it { expect(salesnav_messages_instance.execute).to eq(false) }
      end
    end

    context 'when cannot find message_field_css' do
      before { has_not_selector(session, message_field_css) }
      it { expect { salesnav_messages_instance.execute }.to raise_error(ScrapIn::CssNotFound) }
    end

    context 'when cannot find button_css' do
      before { has_not_selector(session, send_button_css) }
      it { expect { salesnav_messages_instance.execute }.to raise_error(ScrapIn::CssNotFound) }
    end

    context 'when fails to load messages after sending for some reason' do
      before do
        has_not_selector(session, messages_css)
        allow(session).to receive(:all).with(messages_css).and_return(conversation_array, [])
      end
      it { expect(salesnav_messages_instance.execute).to eq(false) }
    end

    context 'when fails to send message for some reason, the last message is not the one expected' do
      before { allow(conversation_array).to receive(:[]).with(-1).and_return(conversation_array[0]) }
      it { expect(salesnav_messages_instance.execute).to eq(false) }
    end

    context 'when class sends message to lead' do
      it { expect(salesnav_messages_instance.execute).to eq(true) }
    end

    context 'when wants the class to do the job but do not send the message' do
      before do
        conversation_array.pop
        salesnav_messages_instance.execute(false)
      end
      it { expect(session).to have_received(:visit) }
      it { expect(message_field_node).to have_received(:send_keys) }
      it { expect(salesnav_messages_instance.execute(false)).to eq(false) }
    end
  end
end
