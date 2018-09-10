module Tools
  def scroll_to(element)
    script = <<-JS
        arguments[0].scrollIntoView(true);
    JS
    @session.driver.browser.execute_script(script, element.native)
  end

  def find_and_click(css)
    unless @session.has_selector?(css)
      @error = "Cannot find action button for css = #{css}"
      return false
    end
    @session.find(css).click
    true
  end
end
