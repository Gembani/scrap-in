# Methods used in some of Salesnavot's classes
module Tools
  def scroll_to(element)
    script = <<-JS
        arguments[0].scrollIntoView(true);
    JS
    @session.driver.browser.execute_script(script, element.native)
  end

  def find_and_click(css)
    unless @session.has_selector?(css)
      @error = css_error(css)
      return false
    end
    @session.find(css).click
    true
  end

  def css_error(css)
    "Wrong CSS, or it has been changed : #{css}"
  end
end
