module Salesnavot
  # Goes on list page and get profile and image links of all leads
  class Search
    include Tools
    include CssSelectors::Search

    def initialize(list_identifier, session)
      @session = session
      @list_identifier = list_identifier
      @links = []
      @saved_search_url = ''
    end

    def execute(page = 1)
      go_to_saved_search

      puts "Processing page = #{page}"

      unless visit_page(page)
        puts "Page #{page} is empty, not scrapping, and returning first page"
        return 1
      end

      find_page_leads do |a, b|
        yield a, b
      end
      page + 1
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
      click_on_page(2)
      return true if page == 2
      url = @session.current_url.sub('page=2', "page=#{page}")
      @session.visit(url)
      return false if empty_results?
      check_results_loaded
      true
    end

    def check_leads_loaded
      raise css_error(name_css) unless @session.has_selector?(name_css, wait: 3)
    end

    def find_leads_size
      items = @session.all(name_css)
      size = items.count
      while size != 25
        scroll_to(items.last)
        items = @session.all(name_css)
        size = items.count
      end
    end

    def find_page_leads
      check_leads_loaded
      find_leads_size
      @session.all(name_css).each do |item|
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
