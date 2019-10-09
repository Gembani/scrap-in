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
    driver = double('driver')
    browser = double('browser')
    allow(session).to receive(:driver).and_return(driver)
    allow(driver).to receive(:browser).and_return(browser)
    allow(browser).to receive(:execute_script)
  end
end
