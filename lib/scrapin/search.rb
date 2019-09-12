module ScrapIn
  # Goes on list page and get profile and image links of all leads
  class Search
    include Tools
    include CssSelectors::Search

    def initialize(list_identifier, session)
      @session = session
      @list_identifier = list_identifier
      @links = []
      @saved_search_url = ''
      @error = nil
      @processed_page = 1
      @max_page = 1
    end

    def execute(page = 1)
      @processed_page = page
      go_to_saved_search

      puts "Processing page = #{@processed_page}"
      @max_page = @session.find(pagination_list_css).all('li').last.find('button').text.to_i

      if @processed_page > @max_page
        @error = "Page #{@processed_page} doesn't exist as the maximum page is #{@max_page}"
        puts @error
        return 1
      end

      unless visit_page(@processed_page)
        @error = "Page #{@processed_page} is empty, not scrapping, and returning first page"
        puts @error
        return 1
      end

      find_page_leads do |a, b|
        yield a, b
      end
      @processed_page + 1
    end

    def check_results_loaded
      raise 'NOT LOADED' unless @session.has_selector?(
        results_loaded_css, wait: 3
      )
    end

    def click_on_page(page)
      @session.all(page_css(page)).first.click
      check_results_loaded
    end

    def empty_results?
      @session.has_selector?(no_results_css, wait: 3)
    end

    # if page 2 empty results fails - don't use this with a too small search!
    def visit_page(page)
      return true if page == 1
      if page == @max_page
        find_leads_size_on_page # in order to scroll to the bottom of the page
        @session.click_button(@max_page)
        return true
      end

      # While "clicking" on page 2, url changes in the way we can substitue "page=x"
      click_on_page(2)
      return true if page == 2

      url = @session.current_url.sub('page=2', "page=#{page}")
      puts "Going to page #{page}"
      @session.visit(url)
      return false if empty_results?
      check_results_loaded
      true
    end

    def find_page_leads
      ensure_leads_are_loaded
      find_leads_size_on_page
      puts "Getting the links and the image source of each profile on the page..."
      @session.all(name_css).each do |item|
        href = item[:href]
        profile_image = if item.has_selector?('img', wait: 0)
                          item.find('img')[:src]
                        end
        puts "Link = #{href}"
        yield href, profile_image
      end
      puts "Done"
    end

    def ensure_leads_are_loaded
      raise CssNotFound.new(name_css) unless @session.has_selector?(name_css)
    end

    def find_leads_size_on_page
      items = @session.all(name_css)
      size = items.count
      while size != 25
        scroll_to(items.last)
        items = @session.all(name_css)
        size = items.count
        break if processing_last_page?
      end
    end

    def processing_last_page?
      @processed_page == @max_page
    end

    def go_to_saved_search
      puts "Going to the Homepage"
      @session.visit(homepage)
      puts "Hovering the mouse over the button 'Saved searches'"
      @session.find(searches_hover_css).hover
      puts "Clicking on the search of interest"
      @session.find(searches_hover_css).find(searches_list_css).find('li',:text=>@list_identifier).click_link
      @saved_search_url = @session.current_url
    end

    def homepage
      'https://www.linkedin.com/sales'
    end
  end
end
