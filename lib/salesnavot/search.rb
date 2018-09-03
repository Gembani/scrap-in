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
      @session.visit("#{url}&page=#{page}")
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
      css = 'search-results__no-results'
      @session.has_selector?(css, wait: 5)
    end

    # Check if there are results in actual page
    def page_is_populated?(page)
      if page != 1
        click_on_page(2)
        visit_start(@session.current_url, page)
      end

      !has_empty_results
    end

    def calculate_last_page
      @session.has_selector?('.artdeco-tab-primary-text')
      total_results = @session.all('.artdeco-tab-primary-text').first.text.to_i
      last_page = total_results / 25
      last_page += 1 if total_results % 25 > 0
      last_page
    end

    def execute(page = 1)
      go_to_saved_search
      last_page = calculate_last_page

      page = 1 unless page.between?(1, last_page)

      puts "Page processed = #{page} cuz last page = #{last_page}"
      return unless page_is_populated?(page)
      get_page_leads(page, last_page) do |a, b|
        yield a, b
      end
      return 1 if page == last_page
      return page + 1
    end

    def get_page_leads(page, last_page)
      @session.has_selector?('.result-lockup__icon-link', wait: 3)
      items = @session.all('a.result-lockup__icon-link')
      size = items.count
      while size != 25 && page != last_page
        scroll_to(items.last)
        items = @session.all('a.result-lockup__icon-link')
        size = items.count
      end
      @session.all('a.result-lockup__icon-link').each do |item|
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
