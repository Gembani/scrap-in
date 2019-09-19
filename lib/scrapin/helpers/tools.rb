# Methods used in some of ScrapIn's classes
module ScrapIn
  module Tools
    def scroll_to(element)
      script = <<-JS
          arguments[0].scrollIntoView(true);
      JS
      @session.driver.browser.execute_script(script, element.native)
    end
    
    def scroll_down_to(element)
      script = <<-JS
          arguments[0].scrollIntoView({block: "end", inline: "nearest", behavior: "smooth"});
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

    def find_and_click(node, css)
      unless node.has_selector?(css)
        raise CssNotFound.new(css)
      end
      node.find(css).click 
    end
    
    def check_and_find_first(node, *config)
      css = config.first
      unless node.has_selector?(*config)
        raise CssNotFound.new(css)
      end
      node.first(*config)
    end

    def check_and_find(node, *config)
      css = config.first
      unless node.has_selector?(*config)
        raise CssNotFound.new(css)
      end
      node.find(*config)
    end

    # def check_and_find_all(node, *config)
    #   css = config.first
    #   unless node.has_selector?(*config)
    #     raise CssNotFound.new(css)
    #   end
    #   node.all(*config)
    # end
    
    def find_xpath_and_click(xpath)
      unless @session.has_selector?(:xpath, xpath)
        raise CssNotFound.new(xpath)
      end
      @session.find(:xpath, xpath).click
    end
  end
end
