module Salesnavot
  class SentInvites
    def initialize(session)
      @session = session
    end

    def execute
      init_list
      loop do
        one_page_links do |link|
          yield link
        end
        break if next_page == false
      end
    end

    def init_list
      @session.visit("https://www.linkedin.com/mynetwork/invitation-manager/sent/")
      while (@session.all('.mn-invitation-list li').count == 0)
        sleep(0.1)
      end

    end

    def one_page_links
      @session.all('.mn-invitation-list li').each do |block|
        name = block.find("a.mn-person-info__link").find(".mn-person-info__name").text
        yield name
      end

    end

    def next_page
      return false if @session.all("a.mn-invitation-pagination__control-btn").last.native.attribute("class").include?("disabled")
      @session.all("a.mn-invitation-pagination__control-btn").last.click
      sleep(5)
      return true
    end
  end
end
