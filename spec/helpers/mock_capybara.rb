module MockCapybara
  def has_selector(node, *config)
    allow(node).to receive(:has_selector?)
      .with(*config).and_return(true)
  end

  def has_not_selector(node, *config)
    allow(node).to receive(:has_selector?)
      .with(*config).and_return(false)
  end

  def visit_succeed(url)
    allow(session).to receive(:visit).with(url)
  end

  def click_button_success(text)
    allow(session).to receive(:click_button).with(text).and_return(true)
  end 

  def click_button_fails(text)
      allow(session).to receive(:click_button).with(text)
                                              .and_raise(Capybara::ElementNotFound, "Unable to find button '#{text}' that is not disabled")
  end 

  def cannot_find_field_with_placeholder(placeholder)
    exception = "Unable to find field that is not disabled with placeholder #{placeholder}"
    allow(session).to receive(:find_field).with(placeholder: placeholder)
                                          .and_raise(Capybara::ElementNotFound, exception)
  end
end