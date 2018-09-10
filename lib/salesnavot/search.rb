module Salesnavot
  # Goes on list page and get profile and image links of all leads
  class Search
    include Tools
    def initialize(list_identifier, session)
      @session = session
      @list_identifier = list_identifier
      @links = []
      @saved_search_url = ''
    end

    def css_results_loaded
      'ol.search-results__result-list li.search-results__result-item div.search-results__result-container'
    end

    def check_results_loaded
      raise "NOT LOADED" unless @session.has_selector?(css_results_loaded, wait: 3)
    end


    def click_on_page(page)
      css = ".cursor-pointer [data-page-number='#{page}']"
      @session.all(css).first.click
      check_results_loaded
    end

    def has_empty_results
      css = '.search-results__no-results'
      @session.has_selector?(css, wait: 3)
    end

    # if page 2 empty results fails - don't use this with a too small search!
    def visit_page(page)
      return true if page == 1
      click_on_page(2)
      return true if page == 2
      url = @session.current_url.sub("page=2", "page=#{page}")
      @session.visit(url)
      return false if has_empty_results
      check_results_loaded
      return true
    end



    def execute(page = 1)
      go_to_saved_search


      puts "Processing page = #{page}"

      unless visit_page(page)
        puts "Page #{page} is empty, not scrapping, and returning first page"
        return 1
      end

      get_page_leads(page) do |a, b|
        yield a, b
      end
      return page + 1
    end

    def get_page_leads(page)
      css = 'dt.result-lockup__name a'
      raise "CSS changed a.name-link doesn't exist" unless @session.has_selector?(css, wait: 3)
      items = @session.all(css)
      size = items.count
      while size != 25
        scroll_to(items.last)
        items = @session.all(css)
        size = items.count
      end
      @session.all(css).each do |item|
        href = item[:href]

        profile_image = if item.has_selector?('img', wait: 0)
                          item.find('img')[:src]
                        end

        puts "Link = #{href}"
        yield href, profile_image
      end
    end

    def go_to_saved_search
      @session.visit(homepage)
      @session.find('.global-nav-saved-searches-button').hover
      @session.find('.global-nav-dropdown-list').click_on(@list_identifier)
      @saved_search_url = @session.current_url
    end

    def homepage
      'https://www.linkedin.com/sales'
    end
  end
end
