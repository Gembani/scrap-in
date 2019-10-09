# Methods used in some of ScrapIn's classes
module ScrapIn
  module Tools
    def scroll_to(element)
      script = <<-JS
          arguments[0].scrollIntoView(true);
      JS
      @session.driver.browser.execute_script(script, element.native)
    end
    
    def scroll_up_to(element)
      script = <<-JS
          arguments[0].scrollIntoView({block: "end", inline: "nearest", behavior: "smooth"});
      JS
      @session.driver.browser.execute_script(script, element.native)
      true
    end

    def check_until(amount_of_time)
      amount_of_time.times do
        return true if yield

        sleep(0.001)
      end
      false
    end

    def find_and_click(node, css)
      raise CssNotFound, css unless node.has_selector?(css)

      node.find(css).click 
    end
    
    def check_and_find_first(node, *config)
      css = config.first
      raise CssNotFound, css unless node.has_selector?(*config)

      node.first(*config)
    end

    def check_and_find(node, *config)
      css = config.first
      raise CssNotFound, css unless node.has_selector?(*config)

      node.find(*config)
    end
    
    def find_xpath_and_click(xpath)
      raise CssNotFound, xpath unless @session.has_selector?(:xpath, xpath)

      @session.find(:xpath, xpath).click
    end
  end
end
