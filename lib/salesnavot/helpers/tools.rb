# Methods used in some of Salesnavot's classes
module Tools
  def scroll_to(element)
    script = <<-JS
        arguments[0].scrollIntoView(true);
    JS
    @session.driver.browser.execute_script(script, element.native)
  end

  def check_until(amount_of_time)
    amount_of_time.times do
      return true if yield
      sleep(0.001)
    end
    return false
  end

  def find_and_click(css)
    unless @session.has_selector?(css)
      @error = css_error(css)
      raise css_error(css)
    end
    @session.find(css).click 
  end
  
  def find_xpath_and_click(xpath)
    unless @session.has_selector?(:xpath, xpath)
      @error = css_error(xpath)
      raise css_error(xpath)
    end
    @session.find(:xpath, xpath).click
  end

  def css_error(css)
    "Wrong CSS, or it has been changed : #{css}"
  end

  def out_of_network?(url, name = '')
    url.include?('OUT_OF_NETWORK') || 
    name.include?('LinkedIn')
  end
end
