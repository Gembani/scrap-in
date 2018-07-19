module Salesnavot
  # Goes on list page and get profile and image links of all leads
  class Search
    def initialize(list_identifier, session)
      @session = session
      @list_identifier = list_identifier
      @links = []
      @saved_search_url = ''
    end

    def visit_start(root_url, start_number)
      @session.visit("#{root_url}&start=#{start_number}")
      @session
        .has_selector?('ul#results-list li.result:first-child  div:first-child')
    end

    def first_result_class
      css = 'ul#results-list li.result:first-child  div:first-child'
      @session.has_selector?(css)
      results = @session.all(css)
      results.first[:class]
    end

    # Check if there are results in actual page
    def page_is_populated?(start_number)
      visit_start(@saved_search_url, start_number)
      return false if first_result_class == 'empty-result'
      true
    end

    def calculate_last_page
      @session.has_selector?('.spotlight-result-count')
      total_results = @session.all('.spotlight-result-count').first.text.to_i
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
        coucou do |a, b|
          yield a, b
        end
        page += 1
      end
    end

    def coucou
      @session.has_selector?('a.image-wrapper.profile-link')
      @session.all('a.image-wrapper.profile-link').each do |item|
        href = item[:href]

        profile_image = if item.has_selector?('img', wait: 0)
                          item.find('img')[:src]
                        end

        yield href, profile_image
      end
    end

    def go_to_saved_search
      # unless @session.current_url == homepage
      @session.visit(homepage)
      # end
      @session.find('.global-nav-saved-searches-button').hover
      @session.find('.global-nav-dropdown-list').click_on(@list_identifier)
      @saved_search_url = @session.current_url
    end

    def homepage
      'https://www.linkedin.com/sales'
    end
  end
end
