module Salesnavot
  class Search
    def initialize(identifier, session)
      @session = session
      @identifier = identifier
      @links = []
    end

    def execute
      init_list
      @links = []
      loop do
          one_page_links do |link|
            yield link
          end
        break if next_page == false
      end
    end

    def init_list
      @session.visit("https://www.linkedin.com/sales")
      sleep(5)
      @session.find(".global-nav-saved-searches-button").hover
      @session.click_on(@identifier)
      sleep(5)
    end

    def one_page_links
      @session.all('a.image-wrapper.profile-link').each do |item|
        href = item.native.property(:href)
        yield href.split("?")[0]
      end
    end

    def next_page
      return false if @session.find("a.next-pagination").native.attribute("class").include?("disabled")
      @session.find("a.next-pagination").click
      sleep(5)
      return true
    end
  end
end
