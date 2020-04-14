# Helpers for mocking Capybara
module MockCapybara
  def has_selector(node, *config)
    allow(node).to receive(:has_selector?)
      .with(*config).and_return(true)
  end

  def has_not_selector(node, *config)
    allow(node).to receive(:has_selector?)
      .with(*config).and_return(false)
  end

  def has_field(node, *config)
    allow(node).to receive(:has_field?).with(*config).and_return(true)
  end

  def has_not_field(node, *config)
    allow(node).to receive(:has_field?).with(*config).and_return(false)
  end

  def find(node, return_value, *config)
    allow(node).to receive(:find).with(*config).and_return(return_value)
  end

  def all(node, return_value, *config)
    allow(node).to receive(:all).with(*config).and_return(return_value)
  end

  def visit_succeed(url)
    allow(session).to receive(:visit).with(url)
  end

  def click_button_success(text)
    allow(session).to receive(:click_button).with(text).and_return(true)
  end

  def click_button_fails(text)
    allow(session).to receive(:click_button)
      .with(text)
      .and_raise(Capybara::ElementNotFound, "Unable to find button '#{text}' that is not disabled")
  end

  def cannot_find_field_with_placeholder(placeholder)
    exception = "Unable to find field that is not disabled with placeholder #{placeholder}"
    allow(session).to receive(:find_field).with(placeholder: placeholder)
                                          .and_raise(Capybara::ElementNotFound, exception)
  end

  def create_node_array(array, size = 1, array_name = 'Default')
    size.times do |count|
      name = "#{array_name} #{count}"
      node = instance_double('Capybara::Node::Element', name)
      array << node
    end
  end

  def disable_script
    unless session.methods.include?(:driver)
      driver = double('driver')
      allow(session).to receive(:driver).and_return(driver)
    end
    unless session.driver.methods.include?(:browser)
      browser = double('browser')
      allow(session.driver).to receive(:browser).and_return(browser)
    end
    allow(session.driver.browser).to receive(:execute_script)
  end

  def mock_tab_switch
    unless session.methods.include?(:driver)
      driver = double('driver')
      allow(session).to receive(:driver).and_return(driver)
    end
    unless session.driver.methods.include?(:browser)
      browser = double('browser')
      allow(session.driver).to receive(:browser).and_return(browser)
    end
    switch_to = double('switch_to')
    window_handles = double('window_handles')
    allow(session.driver.browser).to receive(:switch_to).and_return(switch_to)
    allow(session.driver.browser).to receive(:window_handles).and_return(window_handles)
    allow(switch_to).to receive(:window)
    allow(window_handles).to receive(:first)
    allow(window_handles).to receive(:last)
  end

  def lead_invite_is_not_pending
    more_button = instance_double('Capybara::Node::Element', 'more_button')
    more_dropdown = instance_double('Capybara::Node::Element', 'more_dropdown')
    has_selector(session, css_more_button)
    find(session, more_button, css_more_button)
    allow(more_button).to receive(:click)

    has_selector(session, more_dropdown_css)
    allow(session).to receive(:first).and_return(more_dropdown)
    allow(more_dropdown).to receive(:text).and_return('Follow\nConnect')
  end
end
