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
    def bound(root_url, lower_bound, upper_bound)
      if (lower_bound + 25 == upper_bound )
        puts "last page is #{lower_bound}"
        return lower_bound
      end
      require "rounding"
      current = lower_bound + ((upper_bound - lower_bound) / 2).round_to(25)
      puts "trying page #{current}"
      if (is_page_populated(root_url, current))
        puts "page #{current} populated"
        current = bound(root_url, current, upper_bound)
      else
        puts "page #{current} not populated"
        current = bound(root_url, lower_bound, current)
      end

    end

    def execute(page = 0)
      init_list
      @links = []
      last_page = 2000
      root_url = @session.current_url


      last_page = bound(root_url, 0, last_page)
      nun_pages = last_page / 25
      if (page > nun_pages )
        page = 0

      start_number = page * 25
      puts "start_number = #{start_number}"
      visit_start(root_url, start_number)
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
