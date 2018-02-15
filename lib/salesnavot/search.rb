module Salesnavot
  class Search
    def initialize(identifier, session)
      @session = session
      @identifier = identifier
      @links = []
    end

    def visit_start(root_url, start_number)
      @session.visit("#{root_url}&start=#{start_number}")
      while (@session.all("ul#results-list li.result:first-child  div:first-child").count == 0)
        puts "loading page"
        sleep(1)
      end
    end

    def is_page_populated(root_url, start_number)
      visit_start(root_url, start_number)
      result_item_class = @session.all("ul#results-list li.result:first-child  div:first-child").first.native.attribute(:class)
      if result_item_class == "empty-result"
        return false
      else
        return true
      end
    end


    def execute(page = 0)
      init_list
      @links = []
      last_page = 2000
      root_url = @session.current_url


      start_number = page * 25
      if (!is_page_populated(root_url, start_number))
        page = 0
        visit_start(root_url, 0)
      end
      sleep(4)
      @session.all('a.image-wrapper.profile-link').each do |item|
        href = item.native.property(:href)
        yield href.split("?")[0]
      end

      return page + 1

    end

    def init_list
      @session.visit("https://www.linkedin.com/sales")
      sleep(5)
      @session.find(".global-nav-saved-searches-button").hover


      @session.click_on(@identifier)
      sleep(5)
    end

  end
end
