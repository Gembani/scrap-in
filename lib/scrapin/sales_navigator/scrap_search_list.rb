module ScrapIn
  module SalesNavigator
    # Goes on list page and get profile and image links of all leads
    class ScrapSearchList
      include Tools
      include CssSelectors::SalesNavigator::ScrapSearchList

      def initialize(session, list_identifier)
        @session = session
        @list_identifier = list_identifier
        @links = []
        @saved_search_url = ''
        @error = nil
        @processed_page = 1
        @max_page = 1
        @homepage = 'https://www.linkedin.com/sales'
      end

      def execute(page = 1)
        @processed_page = page
        go_to_saved_search

        puts "Processing page = #{@processed_page}"
        raise ArgumentError, "there is no page #{page} for #{@list_identifier}" unless @session.all(pagination_list_css).count
        @max_page = @session.all(pagination_list_css).last.text.to_i

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

        find_page_leads do |link, image|
          yield link, image
        end
        @processed_page + 1
      end

      def click_on_page(page)
        page_button = @session.all(page_css(page), wait: 30).first
        scroll_to_first = check_until(500) do 
          scroll_to(page_button)
        end
        page_button.click
        
        check_results_loaded
      end

      def check_results_loaded
        raise CssNotFound, results_loaded_css unless check_until(500) do
          @session.has_selector?(results_loaded_css)
        end
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
        puts 'Getting the links and the image source of each profile on the page...'
        @session.all('.result-lockup__icon-link').each do |item|
          link = item[:href]
          profile_image = (check_and_find(item, '.lazy-image')[:src] if item.has_selector?('.lazy-image', wait: 0))
          puts "Link = #{link}"
          puts "Profile_image = #{profile_image}"
          if (item == @session.all('.result-lockup__icon-link').last)
            byebug
          end
          yield link, profile_image
        end
        puts 'Done'
      end

      def ensure_leads_are_loaded
        check_until(500) do
          @session.has_selector?('.result-lockup__icon-link')
        end
      end

      def find_leads_size_on_page
        items = @session.all('.result-lockup__icon-link')
        size = items.count
        count = 0
        while size < 20 && size.positive?
          scroll_to(items.last)
          items = @session.all('.result-lockup__icon-link')
          size = items.count
          # check_until(500) do
          #   !check_and_find(items.last, '.lazy-image')[:src] if items.last.has_selector?('.lazy-image', wait: 0)
          # end
          count += 1
          break if processing_last_page?
        end
      end

      def processing_last_page?
        @processed_page == @max_page
      end

      def go_to_saved_search
        puts 'Going to the Homepage'
        @session.visit(@homepage)
        puts "Hovering the mouse over the button 'Saved searches'"
        check_and_find(@session, searches_hover_css).hover
        puts 'Clicking on the search of interest'
        check_and_find(@session, searches_hover_css + ' li', text: @list_identifier).click_link
        @saved_search_url = @session.current_url
      end
    end
  end
end
