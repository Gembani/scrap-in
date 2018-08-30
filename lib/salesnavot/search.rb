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

    def visit_start(root_url, start_number)
      @session.visit("#{root_url}")
      @session
        .has_selector?('ul#results-list li.result:first-child  div:first-child')
    end

    def click_on_page(page)
      css = ".cursor-pointer [data-page-number='#{page}']"
      @session.all(css).first.click
      @session
        .has_selector?('ul#results-list li.result:first-child  div:first-child', wait: 2)
    end

    def first_result_class
      css = 'ol.search-results__result-list li.search-results__result-item:first-child div.search-results__result-container'
      @session.has_selector?(css, wait: 2)
      results = @session.all(css)
      results.first[:class]
    end

    # Check if there are results in actual page
    def page_is_populated?(start_number)

      if start_number == 0
        visit_start(@saved_search_url, start_number)
      else
        click_on_page(start_number / 25 + 1)
      end

      return false if first_result_class == 'empty-result'
      true
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

      while page <= last_page
        start_number = (page - 1) * 25
        return unless page_is_populated?(start_number)
        get_page_leads(page, last_page) do |a, b|
          yield a, b
        end
        page += 1
      end
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
