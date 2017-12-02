module Salesnavot
  class ProfileViews
    def initialize(session)
      @session = session
    end
    def scroll_to(element)
      script = <<-JS
        arguments[0].scrollIntoView(true);
      JS

      @session.driver.browser.execute_script(script, element.native)
    end
    def css(count)
      "section.me-wvmp-overview__viewers-list article:nth-child(#{count+1})"
    end

    def get_next_block(count)
      block = @session.all(:css, css(count)).first
      if (block == nil)
        puts "block == nil: #{count}"
        scroll_to(@session.all(:css, css(count - 1)).first)
        while (@session.all(:css, css(count)).first == nil)
          sleep(0.1)
        end
        block = @session.all(:css, css(count)).first
      end
      block
    end

    def execute(num_times = 40)
      init_list
      count = 0
      num_times.times do
        block = get_next_block(count)
        if  block.all(".actor-name-with-distance span:nth-child(1)").count == 0
          puts "No name found for #{block.text}"
        else
          name = block.find(".actor-name-with-distance span:nth-child(1)").text
          time_ago = block.find(".me-wvmp-profile-view-card__time-ago").text
          yield time_ago, name
        end
        count = count + 1
    
      end
    end

    def init_list
      @session.visit("https://www.linkedin.com/me/profile-views/")
      while (@session.all(:css, css(0)).first == nil)
        sleep(0.1)
      end

    end

  end
end
