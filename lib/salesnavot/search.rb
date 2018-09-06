module Salesnavot
  # Goes on list page and get profile and image links of all leads
  class Search
    def initialize(list_identifier, session)
      @session = session
      @list_identifier = list_identifier
      @links = []
      @saved_search_url = ''
    end

    def scroll_to(element)
      script = <<-JS
        arguments[0].scrollIntoView(true);
      JS
      @session.driver.browser.execute_script(script, element.native)
    end

    def visit_start(url, page)
      start=(page - 1) * 25
      @session.visit("#{url}&start=#{start}&count=25")
      @session
        .has_selector?('ul#results-list li.result:first-child  div:first-child')
    end

    def click_on_page(page)
      css = ".cursor-pointer [data-page-number='#{page}']"
      @session.all(css).first.click
      @session
        .has_selector?('ul#results-list li.result:first-child  div:first-child', wait: 2)
    end

    def has_empty_results
      css = '.empty-result'
      @session.has_selector?(css, wait: 5)
    end

    # Check if there are results in actual page
    def page_is_populated?(page)
      visit_start(@session.current_url, page) unless page == 1
      !has_empty_results
    end



    def execute(page = 1)
      go_to_saved_search


      puts "Processing page = #{page}"

      unless page_is_populated?(page)
        puts "Page #{page} is empty, not scrapping, and returning first page"
        return 1
      end

      get_page_leads(page) do |a, b|
        yield a, b
      end
      return page + 1
    end

    def get_page_leads(page)
      raise "CSS changed a.name-link doesn't exist" unless @session.has_selector?('a.name-link', wait: 3)
      items = @session.all('a.name-link')
      size = items.count
      while size != 25
        scroll_to(items.last)
        items = @session.all('a.name-link')
        size = items.count
      end
      @session.all('a.name-link').each do |item|
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
