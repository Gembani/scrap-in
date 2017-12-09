module Salesnavot
  class SentInvites
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
      ".mn-invitation-list li:nth-child(#{count+1})"
    end
    def execute
      init_list
      count = 0

      loop do
        item = @session.all(css(count)).first
        if item == nil
          count = 0
          break if next_page == false
        else
          name = item.find("a.mn-person-info__link").find(".mn-person-info__name").text
          yield name
          scroll_to(item)
          count = count + 1
        end
        sleep(0.5)


      end
    end

    def init_list
      puts "visiting invitations sent"
      @session.visit("https://www.linkedin.com/mynetwork/invitation-manager/sent/")

      while (@session.all('.mn-invitation-list li:nth-child(1)').count == 0)
        puts "sleeping"
        sleep(0.2)
      end

    end

    def one_page_links
      puts @session.all('.mn-invitation-list li').count
      @session.all('.mn-invitation-list li').each do |block|
        name = block.find("a.mn-person-info__link").find(".mn-person-info__name").text
        yield name
      end

    end

    def next_page
      return false if @session.all("a.mn-invitation-pagination__control-btn").last.native.attribute("class").include?("disabled")
      @session.all("a.mn-invitation-pagination__control-btn").last.click
      sleep(4)
      return true
    end
  end
end
