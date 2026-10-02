# Methods used in some of ScrapIn's classes
module ScrapIn
  module Tools
    def scroll_to(element)
      script = <<-JS
          arguments[0].scrollIntoView(true);
      JS
      @session.driver.browser.execute_script(script, element.native)
    end

    def scroll_to_bottom
      script = <<-JS
        window.scrollTo(0, document.body.scrollHeight);
      JS
      @session.driver.browser.execute_script(script, @session.find('body').native)
    
    end

    # LinkedIn's new pages scroll main#workspace, not the window, and lazy-load lists while it scrolls
    def scroll_workspace_to_bottom
      script = <<-JS
        var workspace = document.querySelector('main#workspace');
        if (workspace) { workspace.scrollTop = workspace.scrollHeight; }
      JS
      @session.driver.browser.execute_script(script)
    end

    # Scrolls to load more items matching css, returns all the items (which may be the same as before)
    def load_more_items(css, loaded_count)
      scroll_workspace_to_bottom
      try_until_true(5, 1) { @session.all(css, wait: 0).size > loaded_count }
      @session.all(css, wait: 0)
    end

    ## Doesn't work because can't figure out how to disable permissions to use clipboard
    def get_clipboard_contents
      script = <<-JS
        var cb = arguments[0];
        navigator.clipboard.readText().then(function (text) {cb(text)})
      JS
      @session.driver.browser.execute_async_script(script)
    end     
    
    def scroll_up_to(element)
      script = <<-JS
          arguments[0].scrollIntoView({block: "end", inline: "nearest", behavior: "smooth"});
      JS
      @session.driver.browser.execute_script(script, element.native)
      true
    end

    def try_until_true(max_retries, sleep_in_between = 0.001)
      max_retries.times do
        return true if yield

        sleep(sleep_in_between)
      end
      false
    end

    def find_and_click(node, css)
      raise CssNotFound, css unless node.has_selector?(css)

      node.find(css).click
    end
    
    def check_and_find_first(node, *args, **options)
      raise CssNotFound, args.first unless node.has_selector?(*args, **options)

      node.first(*args, **options)
    end

    def check_and_find(node, *args, **options)
      raise CssNotFound, args.first unless node.has_selector?(*args, **options)

      node.find(*args, **options)
    end
    
    def find_xpath_and_click(xpath)
      raise CssNotFound, xpath unless @session.has_selector?(:xpath, xpath)

      @session.find(:xpath, xpath).click
    end
  end
end
